// JavaScript Document
/** This function adds padding to the bottom and top of the #contentDiv so 
 *  that the scrolling text begins at the top of the viewable area and that
 *  the end of the text terminates in the viewable area when the scrollbar is
 *  dragged to the bottom of the screen. It should be run at page load and
 *  should also be added as a handler for when the window is resized.
 */


var consts = {
	patinaTransparencyTop: 105,
	patinaTransparencyBottom: 472,
	bottomMaskTop: 482 // Should match #bottomMask { top: ... } in CSS
};

var padContentF = function (e) {
	
	$('#contentText').css('padding-top', consts.patinaTransparencyTop + 'px');
	$('#contentText').css('padding-bottom', ($(window).height() - consts.patinaTransparencyBottom) + 'px');

	$('#footer').css('height', ($(window).height() - consts.bottomMaskTop) + 'px');


}


$(window).load(padContentF);
$(window).resize(padContentF);

