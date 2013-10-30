$(document).ready(function(){
	handleStarRating();
});

function handleStarRating(){
	$(document).on('mouseenter','.rs', function(){
		//console.log("A");
		$('.own').addClass("rt_" + $('.rs').attr('id'));
	});
};