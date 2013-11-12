handleStarRating = function() {
	var blClicked, iLastId;
	iLastId = 0;
	blClicked = false;
	$(document).on("mouseenter", ".rs", function() {
		iLastId = $(this).attr("id");
		blClicked = false;
		return $(".own").addClass("rt_" + iLastId);
	});
	$(document).on("click", ".rs", function() {
		return blClicked = true;
	});
	return $(document).on("mouseleave", ".rs", function() {
		if (blClicked) {
		}else{
		return $(".own").removeClass("rt_" + iLastId);
	}
	});
 };