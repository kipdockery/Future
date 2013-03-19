#!/usr/local/bin/perl
##############################################################################
# WWWBoard                      Version 2.0 ALPHA 2                          #
# Copyright 1996 Matt Wright    mattw@worldwidemart.com                      #
# Created 10/21/95              Last Modified 11/25/95                       #
# Scripts Archive at:           http://www.worldwidemart.com/scripts/        #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 1996 Matthew M. Wright  All Rights Reserved.                     #
#                                                                            #
# WWWBoard may be used and modified free of charge by anyone so long as      #
# this copyright notice and the comments above remain intact.  By using this #
# code you agree to indemnify Matthew M. Wright from any liability that      #  
# might arise from it's use.                                                 #  
#                                                                            #
# Selling the code for this program without prior written consent is         #
# expressly forbidden.  In other words, please ask first before you try and  #
# make money off of my program.                                              #
#                                                                            #
# Obtain permission before redistributing this software over the Internet or #
# in any other medium.  In all cases copyright and header must remain intact.#
##############################################################################
# Define Variables

require "wwwboard.cfg";

###########################################################################

###########################################################################
# Configure Options

$show_faq = 1;		# 1 - YES; 0 = NO
$allow_html = 1;	# 1 = YES; 0 = NO
$quote_text = 1;	# 1 = YES; 0 = NO
$subject_line = 0;	# 0 = Quote Subject Editable; 1 = Quote Subject 
			#   UnEditable; 2 = Don't Quote Subject, Editable.
$use_time = 1;		# 1 = YES; 0 = NO

# Done
###########################################################################

# Get the Data Number
&get_number;

# Get Form Information
&parse_form;

# Put items into nice variables
&get_variables;

# Open the new file and write information to it.
&new_file;

# Open the Main WWWBoard File to add link
&main_page;

# Now Add Thread to Individual Pages
if ($num_followups >= 1) {
   &thread_pages;
}

# Return the user HTML
&return_html;

# Increment Number
&increment_num;

############################
# Get Data Number Subroutine

sub get_number {
   open(NUMBER,"$basedir/$datafile");
   $num = <NUMBER>;
   close(NUMBER);
   if ($num == 99999)  {
      $num = "1";
   }
   else {
      $num++;
   }
}

#######################
# Parse Form Subroutine

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ s/<!--(.|\n)*-->//g;

      if ($allow_html != 1) {
         $value =~ s/<([^>]|\n)*>//g;
      }
      else {
         unless ($name eq 'body') {
	    $value =~ s/<([^>]|\n)*>//g;
         }
      }

      $FORM{$name} = $value;
   }

}

###############
# Get Variables

sub get_variables {

   if ($FORM{'followup'}) {
      $followup = "1";
      @followup_num = split(/,/,$FORM{'followup'});
      $num_followups = @followups = @followup_num;
      $last_message = pop(@followups);
      $origdate = "$FORM{'origdate'}";
      $origname = "$FORM{'origname'}";
      $origsubject = "$FORM{'origsubject'}";
   }
   else {
      $followup = "0";
   }

   if ($FORM{'name'}) {
      $name = "$FORM{'name'}";
      $name =~ s/"//g;
      $name =~ s/<//g;
      $name =~ s/>//g;
      $name =~ s/\&//g;
   }
   else {
      &error(no_name);
   }

   if ($FORM{'email'} =~ /.*\@.*\..*/) {
      $email = "$FORM{'email'}";
   }

   if ($FORM{'subject'}) {
      $subject = "$FORM{'subject'}";
      $subject =~ s/\&/\&amp\;/g;
      $subject =~ s/"/\&quot\;/g;
   }
   else {
      &error(no_subject);
   }

   if ($FORM{'url'} =~ /.*\:.*\..*/ && $FORM{'url_title'}) {
      $message_url = "$FORM{'url'}";
      $message_url_title = "$FORM{'url_title'}";
   }

   if ($FORM{'img'} =~ /.*tp:\/\/.*\..*/) {
      $message_img = "$FORM{'img'}";
   }

   if ($FORM{'body'}) {
      $body = "$FORM{'body'}";
      $body =~ s/\cM//g;
      $body =~ s/\n\n/<p>/g;
      $body =~ s/\n/<br>/g;

      $body =~ s/&lt;/</g; 
      $body =~ s/&gt;/>/g; 
      $body =~ s/&quot;/"/g;
   }
   else {
      &error(no_body);
   }

   if ($quote_text == 1) {
      $hidden_body = "$body";
      $hidden_body =~ s/</&lt;/g;
      $hidden_body =~ s/>/&gt;/g;
      $hidden_body =~ s/"/&quot;/g;
   }

   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

   # added to correct for years > 2000
   $year += 1900;

   if ($sec < 10) {
      $sec = "0$sec";
   }
   if ($min < 10) {
      $min = "0$min";
   }
   if ($hour < 10) {
      $hour = "0$hour";
   }
   if ($mon < 10) {
      $mon = "0$mon";
   }
   if ($mday < 10) {
      $mday = "0$mday";
   }

   $month = ($mon + 1);

   @months = ("January","February","March","April","May","June","July","August","September","October","November","December");

   if ($use_time == 1) {
      $date = "$hour\:$min\:$sec $month/$mday/$year";
   }
   else {
      $date = "$month/$mday/$year";
   }
   chop($date) if ($date =~ /\n$/);

   # removed the hard coded 19 from year.  Year is now 4 digits.
   #$long_date = "$months[$mon] $mday, 19$year at $hour\:$min\:$sec";
   $long_date = "$months[$mon] $mday, $year at $hour\:$min\:$sec";

}      

#####################
# New File Subroutine

sub new_file {

	open(NEWFILE,">$basedir/$mesgdir/$num\.$ext") || die $!;
	print NEWFILE "<html>\n<head>\n<title>Wire Graffiti - Sights</title>\</head>\n";
	print NEWFILE "<body bgcolor=\"#ffffff\" marginheight=\"0\" marginwidth=\"0\" topmargin=\"0\"";
	print NEWFILE " leftmargin=\"0\" text=\"#000000\" link=\"#AA0000\" vlink=\"#AA0000\">\n";
	print NEWFILE "<map name=\"nav imagemap\"><area shape=\"rect\" coords=\"535, 6, 613, 31\" \n";
	print NEWFILE "href=\"/latest/latest.html\" onmouseover=\"window.status='whats new with wire graffiti';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"449, 5, 526, 28\" \n";
	print NEWFILE "href=\"/register/register.html\" onmouseover=\"window.status=\'join the wire graffiti fan club\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"358, 5, 444, 28\" \n";
	print NEWFILE "href=\"/contact/contact.html\" onmouseover=\"window.status=\'send mail now!\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"522, 33, 588, 60\" \n";
	print NEWFILE "href=\"/sounds/sounds.html\" onmouseover=\"window.status=\'take a listen\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"451, 34, 511, 61\" \n";
	print NEWFILE "href=\"/sights/sights.html\" onmouseover=\"window.status=\'band photos and other stuff\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"374, 34, 439, 62\" \n";
	print NEWFILE "href=\"/things/things.html\" onmouseover=\"window.status=\'buy our stuff\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"306, 32, 366, 61\" \n";
	print NEWFILE "href=\"/places/places.html\" onmouseover=\"window.status=\'upcoming live perfomances, list of appearances\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"235, 33, 297, 63\"\n";
	print NEWFILE "href=\"/people/people.html\" onmouseover=\"window.status=\'band biographies\';return true\">\n";
	print NEWFILE "<area shape=\"rect\" coords=\"170, 30, 230, 61\"\n";
	print NEWFILE "href=\"/index.html\" onmouseover=\"window.status=\'wire graffiti home page\';return true\">\n";
	print NEWFILE "</map>\n<table width=\"621\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print NEWFILE "<tr>\n<td valign=\"TOP\" colspan=2><img src=\"../vertical_nav.GIF\" width=621 height=76 \n";
	print NEWFILE "usemap=\"#nav imagemap\" alt=\"ImageMap - Better use Netscape 2.0+\" hspace=\"0\" vspace=\"0\" border=0></td>\n";
	print NEWFILE "</tr>\n<tr>\n<td valign=\"TOP\" align=\"LEFT\" width=\"149\"><img src=\"../side.GIF\" \n";
	print NEWFILE "align=left width=\"149\" height=\"229\" hspace=\"0\" vspace=\"0\"></td>\n";
	print NEWFILE "<td valign=\"TOP\" align=\"LEFT\"><br><br><br>\n";
	print NEWFILE "<table width=\"472\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print NEWFILE "<tr>\n<td rowspan=\"3\" valign=\"top\"><img src=\"../message_graphic.gif\" \n";
	print NEWFILE "width=73 height=86 border=0 alt=\"\"></td>\n";
	print NEWFILE "<td valign=\"middle\" colspan=\"3\"><img src=\"../message_title.gif\" width=282 height=34 \n";
	print NEWFILE "border=0 alt=\"\"></td>\n</tr>\n<tr>\n";
	print NEWFILE "<td align=\"center\"><img src=\"../icon_magnify.gif\" width=18 height=21 border=0 alt=\"\" hspace=\"3\"><font\n";
	print NEWFILE "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"/wwwboard/index.htm\">View All Messages</a></b></font></td>\n";
	print NEWFILE "<td align=\"center\"><img src=\"../icon_post.gif\" width=13 height=20 border=0 alt=\"\" hspace=\"3\"><font\n";
	print NEWFILE "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"/wwwboard/post.html\">Post a New Message</a></b></font></td>\n";
	print NEWFILE "<td align=\"center\"><img src=\"../icon_reply.gif\" width=14 height=20 border=0 alt=\"\" \n";
	print NEWFILE "hspace=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a \n";
	print NEWFILE "href=\"$basedir/$mesgdir/$num\.$ext#reply\">Post Follow-up to this Message</a></b></font></td>\n";
	print NEWFILE "</tr>\n<tr>\n";
	print NEWFILE "<td colspan=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><br><br><br>\n";
	print NEWFILE "<p><b>Posted by ";
	if ($email) {
      print NEWFILE "<a href=\"mailto:$email\">$name</a> on <em>$long_date:</em></b></p>\n";
	} else {
      print NEWFILE "$name on <em>$long_date:</em></p>\n";
	}
	if ($followup == 1) {
      print NEWFILE "In Reply to: <a href=\"$last_message\.$ext\">$origsubject</a> posted by ";
      if ($origemail) {
         print NEWFILE "<a href=\"$origemail\">$origname</a> on $origdate:<p>\n";
      } else {
         print NEWFILE "$origname on $origdate:<p>\n";
      }
	}
	if ($subject) {
	print NEWFILE "<p><font color=\"#AA0000\"><b>$subject</b></font></p>\n";
	} else {
	print NEWFILE "<p><font color=\"#AA0000\"><b>No Subject</b></font></p>\n";
	}
	print NEWFILE "<p>$body</p>\n";

	print NEWFILE "<hr>\n";
	print NEWFILE "<p><b><a name=\"followups\">Follow Ups:</a></b>\n";
	print NEWFILE "<ul><!--insert: $num-->\n";
	print NEWFILE "</ul><!--end: $num-->\n";

	print NEWFILE "<hr>\n";
	print NEWFILE "<p><b><a name=\"reply\">Post a Followup</a></b></p>\n";
	print NEWFILE "<form method=POST action=\"$cgi_url\">\n";
	print NEWFILE "<input type=hidden name=\"followup\" value=\"";
   if ($followup == 1) {
      foreach $followup_num (@followup_num) {
         print NEWFILE "$followup_num,";
      }
   }
   print NEWFILE "$num\">\n";
   print NEWFILE "<input type=hidden name=\"origname\" value=\"$name\">\n";
   if ($email) {
      print NEWFILE "<input type=hidden name=\"origemail\" value=\"$email\">\n";
   }
   print NEWFILE "<input type=hidden name=\"origsubject\" value=\"$subject\">\n";
   print NEWFILE "<input type=hidden name=\"origdate\" value=\"$long_date\">\n";
   print NEWFILE "<p><b>Name:</b><br><input type=text name=\"name\" size=15></p>\n";
   print NEWFILE "<p><b>E-Mail:</b><br><input type=text name=\"email\" size=15></p>\n";
   if ($subject_line == 1) {
      if ($subject_line =~ /^Re:/) {
         print NEWFILE "<input type=hidden name=\"subject\" value=\"$subject\">\n";
         print NEWFILE "<p><b>Subject:</b> $subject</p>\n";
      }
      else {
         print NEWFILE "<input type=hidden name=\"subject\" value=\"Re: $subject\">\n";
         print NEWFILE "<p><b>Subject:</b> Re: $subject</p>\n";
      }
   }
   elsif ($subject_line == 2) {
      print NEWFILE "<p><b>Subject:</b> <input type=text name=\"subject\" size=15></p>\n";
   }
   else {
      if ($subject =~ /^Re:/) {
         print NEWFILE "<p><b>Subject:</b> <input type=text name=\"subject\"value=\"$subject\" size=15></p>\n";
      }
      else {
         print NEWFILE "<p><b>Subject:</b> <input type=text name=\"subject\" value=\"Re: $subject\" size=15></p>\n";
      }
   }
   print NEWFILE "<p><b>Message:</b><br>\n";
   print NEWFILE "<textarea name=\"body\" COLS=40 ROWS=7>\n";
   if ($quote_text == 1) {
      @chunks_of_body = split(/\&lt\;p\&gt\;/,$hidden_body);
      foreach $chunk_of_body (@chunks_of_body) {
         @lines_of_body = split(/\&lt\;br\&gt\;/,$chunk_of_body);
         foreach $line_of_body (@lines_of_body) {
            print NEWFILE ": $line_of_body\n";
         }
         print NEWFILE "\n";
      }
   }
   print NEWFILE "</textarea></p>\n";
   print NEWFILE "<p>\n";
   print NEWFILE "<input type=submit value=\"Submit Follow Up\"> <input type=reset></p>\n";
   print NEWFILE "</form></td></tr></table></body></html>\n";
   close(NEWFILE);
}

###############################
# Main WWWBoard Page Subroutine

sub main_page {
   open(MAIN,"$basedir/$mesgfile") || die $!;
   @main = <MAIN>;
   close(MAIN);

   open(MAIN,">$basedir/$mesgfile") || die $!;
   if ($followup == 0) {
      foreach $main_line (@main) {
         if ($main_line =~ /<!--begin-->/) {
            print MAIN "<!--begin-->\n";
	    print MAIN "<!--top: $num--><li><a href=\"$mesgdir/$num\.$ext\">$subject</a> - <b>$name</b> <i>$date</i>\n";
            print MAIN "(<!--responses: $num-->0)\n";
            print MAIN "<ul><!--insert: $num-->\n";
            print MAIN "</ul><!--end: $num-->\n";
         }
         else {
            print MAIN "$main_line";
         }
      }
   }
   else {
      foreach $main_line (@main) {
	 $work = 0;
         if ($main_line =~ /<ul><!--insert: $last_message-->/) {
            print MAIN "<ul><!--insert: $last_message-->\n";
            print MAIN "<!--top: $num--><li><a href=\"$mesgdir/$num\.$ext\">$subject</a> - <b>$name</b> <i>$date</i>\n";
            print MAIN "(<!--responses: $num-->0)\n";
            print MAIN "<ul><!--insert: $num-->\n";
            print MAIN "</ul><!--end: $num-->\n";
         }
         elsif ($main_line =~ /\(<!--responses: (.*)-->(.*)\)/) {
            $response_num = $1;
            $num_responses = $2;
            $num_responses++;
            foreach $followup_num (@followup_num) {
               if ($followup_num == $response_num) {
                  print MAIN "(<!--responses: $followup_num-->$num_responses)\n";
		  $work = 1;
               }
            }
            if ($work != 1) {
               print MAIN "$main_line";
            }
         }
         else {
            print MAIN "$main_line";
         }
      }
   }
   close(MAIN);
}

############################################
# Add Followup Threading to Individual Pages
sub thread_pages {

   foreach $followup_num (@followup_num) {
      open(FOLLOWUP,"$basedir/$mesgdir/$followup_num\.$ext");
      @followup_lines = <FOLLOWUP>;
      close(FOLLOWUP);

      open(FOLLOWUP,">$basedir/$mesgdir/$followup_num\.$ext");
      foreach $followup_line (@followup_lines) {
         $work = 0;
         if ($followup_line =~ /<ul><!--insert: $last_message-->/) {
	    print FOLLOWUP "<ul><!--insert: $last_message-->\n";
            print FOLLOWUP "<!--top: $num--><li><a href=\"$num\.$ext\">$subject</a> <b>$name</b> &nbsp; <i>$date</i>\n";
            print FOLLOWUP "(<!--responses: $num-->0)\n";
            print FOLLOWUP "<ul><!--insert: $num-->\n";
            print FOLLOWUP "</ul><!--end: $num-->\n";
         }
         elsif ($followup_line =~ /\(<!--responses: (.*)-->(.*)\)/) {
            $response_num = $1;
            $num_responses = $2;
            $num_responses++;
            foreach $followup_num (@followup_num) {
               if ($followup_num == $response_num) {
                  print FOLLOWUP "(<!--responses: $followup_num-->$num_responses)\n";
                  $work = 1;
               }
            }
            if ($work != 1) {
               print FOLLOWUP "$followup_line";
            }
         }
         else {
            print FOLLOWUP "$followup_line";
         }
      }
      close(FOLLOWUP);
   }
}

sub return_html {
   print "Content-type: text/html\n\n";
   print "<html>\n<head>\n<title>Wire Graffiti - Sights</title>\</head>\n";
   print "<body bgcolor=\"#ffffff\" marginheight=\"0\" marginwidth=\"0\" topmargin=\"0\"";
   print " leftmargin=\"0\" text=\"#000000\" link=\"#AA0000\" vlink=\"#AA0000\">\n";
   print "<map name=\"nav imagemap\"><area shape=\"rect\" coords=\"535, 6, 613, 31\" \n";
   print "href=\"../latest/latest.html\" onmouseover=\"window.status='whats new with wire graffiti';return true\">\n";
   print "<area shape=\"rect\" coords=\"449, 5, 526, 28\" \n";
   print "href=\"../register/register.html\" onmouseover=\"window.status=\'join the wire graffiti fan club\';return true\">\n";
   print "<area shape=\"rect\" coords=\"358, 5, 444, 28\" \n";
   print "href=\"../contact/contact.html\" onmouseover=\"window.status=\'send mail now!\';return true\">\n";
   print "<area shape=\"rect\" coords=\"522, 33, 588, 60\" \n";
   print "href=\"../sounds/sounds.html\" onmouseover=\"window.status=\'take a listen\';return true\">\n";
   print "<area shape=\"rect\" coords=\"451, 34, 511, 61\" \n";
   print "href=\"sights.html\" onmouseover=\"window.status=\'band photos and other stuff\';return true\">\n";
   print "<area shape=\"rect\" coords=\"374, 34, 439, 62\" \n";
   print "href=\"../things/things.html\" onmouseover=\"window.status=\'buy our stuff\';return true\">\n";
   print "<area shape=\"rect\" coords=\"306, 32, 366, 61\" \n";
   print "href=\"../places/places.html\" onmouseover=\"window.status=\'upcoming live perfomances, list of appearances\';return true\">\n";
   print "<area shape=\"rect\" coords=\"235, 33, 297, 63\"\n";
   print "href=\"../people/people.html\" onmouseover=\"window.status=\'band biographies\';return true\">\n";
   print "<area shape=\"rect\" coords=\"170, 30, 230, 61\"\n";
   print "href=\"../index.html\" onmouseover=\"window.status=\'wire graffiti home page\';return true\">\n";
   print "</map>\n<table width=\"621\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
   print "<tr>\n<td valign=\"TOP\" colspan=2><img src=\"../wwwboard/vertical_nav.GIF\" width=621 height=76 \n";
   print "usemap=\"#nav imagemap\" alt=\"ImageMap - Better use Netscape 2.0+\" hspace=\"0\" vspace=\"0\" border=0></td>\n";
   print "</tr>\n<tr>\n<td valign=\"TOP\" align=\"LEFT\" width=\"149\"><img src=\"../wwwboard/side.GIF\" \n";
   print "align=left width=\"149\" height=\"229\" hspace=\"0\" vspace=\"0\"></td>\n";
   print "<td valign=\"TOP\" align=\"LEFT\"><br><br><br>\n";
   print "<table width=\"472\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
   print "<tr>\n<td rowspan=\"3\" valign=\"top\"><img src=\"../wwwboard/message_graphic.gif\" \n";
   print "width=73 height=86 border=0 alt=\"\"></td>\n";
   print "<td valign=\"middle\" colspan=\"3\"><img src=\"../wwwboard/message_title.gif\" width=282 height=34 \n";
   print "border=0 alt=\"\"></td>\n</tr>\n<tr valign=\"middle\">\n";
   print "<td align=\"center\"><img src=\"../wwwboard/icon_magnify.gif\" width=18 height=21 border=0 alt=\"\" hspace=\"3\"><font\n";
   print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"/wwwboard/index.htm\">View All Messages</a></b></font></td>\n";
   print "<td align=\"center\"><img src=\"../wwwboard/icon_post.gif\" width=13 height=20 border=0 alt=\"\" hspace=\"3\"><font\n";
   print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"/wwwboard/post.html\">Post a New Message</a></b></font></td>\n";
   print "<td align=\"center\"><img src=\"../wwwboard/icon_reply.gif\" width=14 height=20 border=0 alt=\"\" \n";
   print "hspace=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a \n";
   print "href=\"$basedir/$mesgdir/$num\.$ext#reply\">Post Follow-up to this Message</a></b></font></td>\n";
   print " </tr>\n         <tr>\n";
   print "                 <td colspan=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><br><br><br>\n";
   print "<p><b>Message Added: $subject</b></p><hr><p>\n";
   print "The following information was added to the message board:</p><p>\n";
   print "<b>Name:</b> $name<br>\n";
   print "<b>E-Mail:</b> $email<br>\n";
   print "<b>Subject:</b> $subject<br>\n";
   print "<b>Body of Message:</b></p>\n";
   print "$body<p>\n";
   if ($message_url) {
      print "<b>Link:</b> <a href=\"$message_url\">$message_url_title</a><br>\n";
   }
   if ($message_img) {
      print "<b>Image:</b> <img src=\"$message_img\"><br>\n";
   }
   print "<b>Added on Date:</b> $date<p>\n";
   print "<a href=\"$baseurl/$mesgdir/$num\.$ext\">Go to Your Message</a> | <a href=\"$baseurl/$mesgfile\">$title</a>\n";
   print "</td></tr></table></td></tr></table>";
   print "</body></html>\n";
}

sub increment_num {
   open(NUM,">$basedir/$datafile") || die $!;
   print NUM "$num";
   close(NUM);
}

sub error {
   $error = $_[0];

   print "Content-type: text/html\n\n";

   if ($error eq 'no_name') {
	print "<html>\n<head>\n<title>Wire Graffiti - $title ERROR</title>\</head>\n";
	print "<body bgcolor=\"#ffffff\" marginheight=\"0\" marginwidth=\"0\" topmargin=\"0\"";
	print " leftmargin=\"0\" text=\"#000000\" link=\"#AA0000\" vlink=\"#AA0000\">\n";
	print "<map name=\"nav imagemap\"><area shape=\"rect\" coords=\"535, 6, 613, 31\" \n";
	print "href=\"../latest/latest.html\" onmouseover=\"window.status='whats new with wire graffiti';return true\">\n";
	print "<area shape=\"rect\" coords=\"449, 5, 526, 28\" \n";
	print "href=\"../register/register.html\" onmouseover=\"window.status=\'join the wire graffiti fan club\';return true\">\n";
	print "<area shape=\"rect\" coords=\"358, 5, 444, 28\" \n";
	print "href=\"../contact/contact.html\" onmouseover=\"window.status=\'send mail now!\';return true\">\n";
	print "<area shape=\"rect\" coords=\"522, 33, 588, 60\" \n";
	print "href=\"../sounds/sounds.html\" onmouseover=\"window.status=\'take a listen\';return true\">\n";
	print "<area shape=\"rect\" coords=\"451, 34, 511, 61\" \n";
	print "href=\"sights.html\" onmouseover=\"window.status=\'band photos and other stuff\';return true\">\n";
	print "<area shape=\"rect\" coords=\"374, 34, 439, 62\" \n";
	print "href=\"../things/things.html\" onmouseover=\"window.status=\'buy our stuff\';return true\">\n";
	print "<area shape=\"rect\" coords=\"306, 32, 366, 61\" \n";
	print "href=\"../places/places.html\" onmouseover=\"window.status=\'upcoming live perfomances, list of appearances\';return true\">\n";
	print "<area shape=\"rect\" coords=\"235, 33, 297, 63\"\n";
	print "href=\"../people/people.html\" onmouseover=\"window.status=\'band biographies\';return true\">\n";
	print "<area shape=\"rect\" coords=\"170, 30, 230, 61\"\n";
	print "href=\"../index.html\" onmouseover=\"window.status=\'wire graffiti home page\';return true\">\n";
	print "</map>\n<table width=\"621\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print "<tr>\n<td valign=\"TOP\" colspan=2><img src=\"./vertical_nav.GIF\" width=621 height=76 \n";
	print "usemap=\"#nav imagemap\" alt=\"ImageMap - Better use Netscape 2.0+\" hspace=\"0\" vspace=\"0\" border=0></td>\n";
	print "</tr>\n<tr>\n<td valign=\"TOP\" align=\"LEFT\" width=\"149\"><img src=\"./side.GIF\" \n";
	print "align=left width=\"149\" height=\"229\" hspace=\"0\" vspace=\"0\"></td>\n";
	print "<td valign=\"TOP\" align=\"LEFT\"><br><br><br>\n";
	print "<table width=\"472\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print "<tr>\n<td rowspan=\"3\" valign=\"top\"><img src=\"./message_graphic.gif\" \n";
	print "width=73 height=86 border=0 alt=\"\"></td>\n";
	print "<td valign=\"middle\" colspan=\"3\"><img src=\"./message_title.gif\" width=282 height=34 \n";
	print "border=0 alt=\"\"></td>\n</tr>\n<tr>\n";
	print "<td align=\"center\"><img src=\"./icon_magnify.gif\" width=18 height=21 border=0 alt=\"\" hspace=\"3\"><font\n";
	print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"./index.html\">View All Messages</a></b></font></td>\n";
	print "<td align=\"center\"><img src=\"./icon_post.gif\" width=13 height=20 border=0 alt=\"\" hspace=\"3\"><font\n";
	print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"./post.html\">Post a New Message</a></b></font></td>\n";
	print "<td align=\"center\"><img src=\"./icon_reply.gif\" width=14 height=20 border=0 alt=\"\" \n";
	print "hspace=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a \n";
	print "href=\"#reply\">Post Follow-up to this Message</a></b></font></td>\n";
	print "	</tr>\n<tr>\n";
	print "<td colspan=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><br><br><br>\n";
	print "<b>ERROR: No Name</b><br>\n";
	print "You forgot to fill in the 'Name' field in your posting. Correct \n";
	print "it below and re-submit.  The necessary fields are: Name, Subject and Message.\n";
	&rest_of_form;
   }
   elsif ($error eq 'no_subject') {
	print "<html>\n<head>\n<title>Wire Graffiti - $title ERROR</title>\</head>\n";
	print "<body bgcolor=\"#ffffff\" marginheight=\"0\" marginwidth=\"0\" topmargin=\"0\"";
	print " leftmargin=\"0\" text=\"#000000\" link=\"#AA0000\" vlink=\"#AA0000\">\n";
	print "<map name=\"nav imagemap\"><area shape=\"rect\" coords=\"535, 6, 613, 31\" \n";
	print "href=\"../latest/latest.html\" onmouseover=\"window.status='whats new with wire graffiti';return true\">\n";
	print "<area shape=\"rect\" coords=\"449, 5, 526, 28\" \n";
	print "href=\"../register/register.html\" onmouseover=\"window.status=\'join the wire graffiti fan club\';return true\">\n";
	print "<area shape=\"rect\" coords=\"358, 5, 444, 28\" \n";
	print "href=\"../contact/contact.html\"onmouseover=\"window.status=\'send mail now!\';return true\">\n";
	print "<area shape=\"rect\" coords=\"522, 33, 588, 60\" \n";
	print "href=\"../sounds/sounds.html\" onmouseover=\"window.status=\'take a listen\';return true\">\n";
	print "<area shape=\"rect\" coords=\"451, 34, 511, 61\" \n";
	print "href=\"sights.html\" onmouseover=\"window.status=\'band photos and other stuff\';return true\">\n";
	print "<area shape=\"rect\" coords=\"374, 34, 439, 62\" \n";
	print "href=\"../things/things.html\" onmouseover=\"window.status=\'buy our stuff\';return true\">\n";
	print "<area shape=\"rect\" coords=\"306, 32, 366, 61\" \n";
	print "href=\"../places/places.html\" onmouseover=\"window.status=\'upcoming live perfomances, list of appearances\';return true\">\n";
	print "<area shape=\"rect\" coords=\"235, 33, 297, 63\"\n";
	print "href=\"../people/people.html\" onmouseover=\"window.status=\'band biographies\';return true\">\n";
	print "<area shape=\"rect\" coords=\"170, 30, 230, 61\"\n";
	print "href=\"../index.html\" onmouseover=\"window.status=\'wire graffiti home page\';return true\">\n";
	print "</map>\n<table width=\"621\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print "<tr>\n<td valign=\"TOP\" colspan=2><img src=\"vertical_nav.GIF\" width=621 height=76 \n";
	print "usemap=\"#nav imagemap\" alt=\"ImageMap - Better use Netscape 2.0+\" hspace=\"0\" vspace=\"0\" border=0></td>\n";
	print "</tr>\n<tr>\n<td valign=\"TOP\" align=\"LEFT\" width=\"149\"><img src=\"side.GIF\" \n";
	print "align=left width=\"149\" height=\"229\" hspace=\"0\" vspace=\"0\"></td>\n";
	print "<td valign=\"TOP\" align=\"LEFT\"><br><br><br>\n";
	print "<table width=\"472\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print "<tr>\n<td rowspan=\"3\" valign=\"top\"><img src=\"message_graphic.gif\" \n";
	print "width=73 height=86 border=0 alt=\"\"></td>\n";
	print "<td valign=\"middle\" colspan=\"3\"><img src=\"message_title.gif\" width=282 height=34 \n";
	print "border=0 alt=\"\"></td>\n</tr>\n<tr>\n";
	print "<td align=\"center\"><img src=\"../icon_magnify.gif\" width=18 height=21 border=0 alt=\"\" hspace=\"3\"><font\n";
	print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"index.html\">View All Messages</a></b></font></td>\n";
	print "<td align=\"center\"><img src=\"../icon_post.gif\" width=13 height=20 border=0 alt=\"\" hspace=\"3\"><font\n";
	print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"post.html\">Post a New Message</a></b></font></td>\n";
	print "<td align=\"center\"><img src=\"../icon_reply.gif\" width=14 height=20 border=0 alt=\"\" \n";
	print "hspace=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a \n";
        print "href=\"#reply\">Post Follow-up to this Message</a></b></font></td>\n";
        print "</tr>\n<tr valign=\"top\">\n";
        print "<td colspan=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><br><br><br>\n";
	print "<b>ERROR: No Subject</b><br>\n";
	print "You forgot to fill in the 'Subject' field in your posting. Correct it below and re-submit.  The necessary fields are: Name, Subject and Message.<p><hr size=7 width=75%><p>\n";
	&rest_of_form;
   }
   elsif ($error eq 'no_body') {
	print "<html>\n<head>\n<title>Wire Graffiti - $title ERROR</title>\</head>\n";
	print "<body bgcolor=\"#ffffff\" marginheight=\"0\" marginwidth=\"0\" topmargin=\"0\"";
	print " leftmargin=\"0\" text=\"#000000\" link=\"#AA0000\" vlink=\"#AA0000\">\n";
	print "<map name=\"nav imagemap\"><area shape=\"rect\" coords=\"535, 6, 613, 31\" \n";
	print "href=\"../latest/latest.html\" onmouseover=\"window.status='whats new with wire graffiti';return true\">\n";
	print "<area shape=\"rect\" coords=\"449, 5, 526, 28\" \n";
	print "href=\"../register/register.html\" onmouseover=\"window.status=\'join the wire graffiti fan club\';return true\">\n";
	print "<area shape=\"rect\" coords=\"358, 5, 444, 28\" \n";
	print "href=\"../contact/contact.html\" onmouseover=\"window.status=\'send mail now!\';return true\">\n";
	print "<area shape=\"rect\" coords=\"522, 33, 588, 60\" \n";
	print "href=\"../sounds/sounds.html\" onmouseover=\"window.status=\'take a listen\';return true\">\n";
	print "<area shape=\"rect\" coords=\"451, 34, 511, 61\" \n";
	print "href=\"sights.html\" onmouseover=\"window.status=\'band photos and other stuff\';return true\">\n";
	print "<area shape=\"rect\" coords=\"374, 34, 439, 62\" \n";
	print "href=\"../things/things.html\" onmouseover=\"window.status=\'buy our stuff\';return true\">\n";
	print "<area shape=\"rect\" coords=\"306, 32, 366, 61\" \n";
	print "href=\"../places/places.html\" onmouseover=\"window.status=\'upcoming live perfomances, list of appearances\';return true\">\n";
	print "<area shape=\"rect\" coords=\"235, 33, 297, 63\"\n";
	print "href=\"../people/people.html\" onmouseover=\"window.status=\'band biographies\';return true\">\n";
	print "<area shape=\"rect\" coords=\"170, 30, 230, 61\"\n";
	print "href=\"../index.html\" onmouseover=\"window.status=\'wire graffiti home page\';return true\">\n";
	print "</map>\n<table width=\"621\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print "<tr>\n<td valign=\"TOP\" colspan=2><img src=\"./vertical_nav.GIF\" width=621 height=76 \n";
	print "usemap=\"#nav imagemap\" alt=\"ImageMap - Better use Netscape 2.0+\" hspace=\"0\" vspace=\"0\" border=0></td>\n";
	print "</tr>\n<tr>\n<td valign=\"TOP\" align=\"LEFT\" width=\"149\"><img src=\"./side.GIF\" \n";
	print "align=left width=\"149\" height=\"229\" hspace=\"0\" vspace=\"0\"></td>\n";
	print "<td valign=\"TOP\" align=\"LEFT\"><br><br><br>\n";
	print "<table width=\"472\" align=\"LEFT\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n";
	print "<tr>\n<td rowspan=\"3\" valign=\"top\"><img src=\"./message_graphic.gif\" \n";
	print "width=73 height=86 border=0 alt=\"\"></td>\n";
	print "<td valign=\"middle\" colspan=\"3\"><img src=\"./message_title.gif\" width=282 height=34 \n";
	print "border=0 alt=\"\"></td>\n</tr>\n<tr>\n";
	print "<td align=\"center\"><img src=\"./icon_magnify.gif\" width=18 height=21 border=0 alt=\"\" hspace=\"3\"><font\n";
	print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"./index.html\">View All Messages</a></b></font></td>\n";
	print "<td align=\"center\"><img src=\"./icon_post.gif\" width=13 height=20 border=0 alt=\"\" hspace=\"3\"><font\n";
	print "face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a href=\"./post.html\">Post a New Message</a></b></font></td>\n";
	print "<td align=\"center\"><img src=\"./icon_reply.gif\" width=14 height=20 border=0 alt=\"\" \n";
	print "hspace=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><b><a \n"; 
	print "href=\"#reply\">Post Follow-up to this Message</a></b></font></td>\n";
        print "</tr>\n<tr valign=\"top\">\n";
        print "<td colspan=\"3\"><font face=\"verdana, arial, helvetica, geneva\" size=\"1\"><br><br><br>\n";
        print "</td></tr><tr valign=\"top\"><td colspan=\"3\"><br><br><br>\n";
	print "<b>ERROR: No Message</b><br>\n";
	print "<p>You forgot to fill in the 'Message' field in your posting. Correct it below and re-submit.  The necessary fields are: Name, Subject and Message.</p><hr>\n";
	&rest_of_form;
   }
   else {
      print "ERROR!  Undefined.\n";
   }
   exit;
}

sub rest_of_form {

   print "<form method=POST action=\"$cgi_url\">\n";

   if ($followup == 1) {
      print "<input type=hidden name=\"origsubject\" value=\"$FORM{'origsubject'}\">\n";
      print "<input type=hidden name=\"origname\" value=\"$FORM{'origname'}\">\n";
      print "<input type=hidden name=\"origemail\" value=\"$FORM{'origemail'}\">\n";
      print "<input type=hidden name=\"origdate\" value=\"$FORM{'origdate'}\">\n";
      print "<input type=hidden name=\"followup\" value=\"$FORM{'followup'}\">\n";
   }
   print "<p><b>Name:</b><br><input type=text name=\"name\" value=\"$FORM{'name'}\" size=15></p>\n";
   print "<p><b>E-Mail:</b><br><input type=text name=\"email\" value=\"$FORM{'email'}\" size=15></p>\n";
   if ($subject_line == 1) {
      print "<input type=hidden name=\"subject\" value=\"$FORM{'subject'}\">\n";
   }
   print "<p><b>Subject:</b><br><input type=text name=\"subject\" value=\"$FORM{'subject'}\" size=15></p>\n";
   print "<p><b>Message:</b><br>\n";
   print "<textarea COLS=40 ROWS=7 name=\"body\">\n";
   $FORM{'body'} =~ s/</&lt;/g;
   $FORM{'body'} =~ s/>/&gt;/g;
   $FORM{'body'} =~ s/"/&quot;/g;
   print "$FORM{'body'}\n";
   print "</textarea><br>\n";
   print "<input type=submit value=\"Post Message\"> <input type=reset>\n";
   print "</form>\n";
   print "<br></td></tr></table></td></tr></table>\n";
   print "</body></html>\n";
}