$(document).ready(function(){
	handleStarRating();
});

function handleStarRating(){
	var iLastId = 0;
	
	$(document).on('mouseenter','.rs', function(){
		console.log("Klasse anfügen");
		
		iLastId = $(this).attr('id');
		$('.own').addClass("rt_" + iLastId);
	});
	$(document).on('mouseleave','.rs', function(){
		console.log("Klasse wegnehmen");
		$('.own').removeClass("rt_" + iLastId);
	});
};