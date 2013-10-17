/**
 * On Document Ready
 * @author ja
 */
$(document).ready(function(){
	init();
});

function init(){
	// On click
	$('#movieTitleGo').click(function(){
		var sName = $("#movieTitle").val();
		alert(sName);
		return false;
	});
};