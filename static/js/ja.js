$(document).ready(function(){
	handleStarRating();
});

function handleStarRating(){
	$('.rs').hover(function(){
		$('.own').addClass("rt_" + $('.rs').attr('id'));
	});
	//alert('handleStarRating');
};