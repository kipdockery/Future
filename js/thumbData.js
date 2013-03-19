/** Contains meta data about thumbnail images. Images are stored in a single
 *  file called images/gallery/thumbnail-strip.jpg. New images can simply be
 *  added to this file, with ic poistioned as a background using the constants
 *  defined below.
 */
var thumbData = {
	image : {  // Each image should have identical dimentions (given in pixels).
		width: 160,
		height: 121
	},
	images : [ // Images should be in the same order as they appear in the sprite.
		{
			image: 'tawina-1.jpg',
			caption: "Hair &amp; Make Up:  Katherine Sawyer<br />\nWardrobe:  Quiet Clothing<br />\nPhotography:  Tressa Pack<br />\nModel:   Tawnia Queen"
		},
		{
			image: 'melissa-3.jpg',
			caption: "Styling &amp; Make Up:  Kaitrin Sears<br />\nHair Color:  Katherine Sawyer, Kaitrin Sears<br />\nWardrobe:  Quiet Clothing<br />\nPhotography:  Tressa Pack<br />\nModel:   Melissa Karakash"
		},
		{
			image: 'clarity-1.jpg',
			caption: "Hair &amp; Make Up:  Katherine Sawyer<br />\nWardrobe:  Quiet Clothing<br />\nPhotography:  Tressa Pack<br />\nModel:   Clarity Coffman"
		},
		{
			image: 'melissa-2.jpg',
			caption: "Styling &amp; Make Up:  Kaitrin Sears<br />\nHair Color:  Katherine Sawyer, Kaitrin Sears<br />\nWardrobe:  Quiet Clothing<br />\nPhotography:  Tressa Pack<br />\nModel:   Melissa Karakashn"
		},
		{
			image: 'clarity-2.jpg',
			caption: "Hair &amp; Make Up:  Katherine Sawyer<br />\nWardrobe:  Quiet Clothing<br />\nPhotography:  Tressa Pack<br />\nModel:   Clarity Coffman"
		},
		{
			image: 'melissa-1.jpg',
			caption: "Styling &amp Make Up:  Kaitrin Sears<br />\nHair Color:  Katherine Sawyer, Kaitrin Sears<br />\nWardrobe:  Quiet Clothing<br />\nPhotography:  Tressa Pack<br />\nModel:   Melissa Karakash"
		},
		{
			image: 'jordan-1.jpg',
			caption: "Hair &amp; Make Up:  Cari Geldreich<br />Wardrobe:  Quiet Clothing<br />Photography:  Tressa Pack<br />Model:   Jordan Pierce"
		}
	]
};


$(window).load(function() {
		
	/** Inserts the thumbnail images.
	 *  @param integer cols The number of columns in which to arrange the thumbnails. Defaults to 2.
	 */
	thumbData.insertThumbCols = function (cols) {
		//console.log(thumbData);
		if (undefined === cols) {
			cols = 2;
		}
		
		// Create a breaker div to insert between rows.
		var breakerDiv = $('<div>').addClass('breaker').text('<!-- -->');
		
		var numThumbsInserted = 0;
		
		while (numThumbsInserted < thumbData.images.length) {
			if (numThumbsInserted != 0 && numThumbsInserted % cols == 0) {
				$('#contentText').append(breakerDiv);
			}
			
			var newThumb = $('<img />');
			newThumb.attr('src', 'images/1px-trans.png');
			newThumb.attr('width', thumbData.image.width);
			newThumb.attr('height', thumbData.image.height);
			newThumb.css('background-position', (-1 * (thumbData.image.width * numThumbsInserted)) + 'px 0px');
			newThumb.addClass('thumbnail');
			
			// Assigning this function to the thumbnail makes the click event display the large image on the left.
			newThumb.click(function(i) {
				return function () {
					//console.log('Image clicked. ' + i);
					var newPhoto = $('<img />');
					newPhoto.attr('src', 'images/gallery/' + thumbData.images[i].image);
					
					$('#photo').empty();
					$('#photo').append(newPhoto);
					
					$('#caption').empty();
					$('#caption').append(thumbData.images[i].caption);
				}
			}(numThumbsInserted));
			
			$('#contentText').append(newThumb);
			
			numThumbsInserted++;
		}
		padContentF();
	}
	
	// Set the initial photo that loads in the gallery.
	var newPhoto = $('<img />');
	var newPhotoDataIndex = 6;
	newPhoto.attr('src', 'images/gallery/' + thumbData.images[newPhotoDataIndex].image); // Images are counted left to right in the thumbnails. The first image is counted as 0.
	
	$('#photo').empty();
	$('#photo').append(newPhoto);
	$('#caption').append(thumbData.images[newPhotoDataIndex].caption);

	delete(newPhoto);
	
});