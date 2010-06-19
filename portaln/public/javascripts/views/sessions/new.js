jQuery(document).ready(function(){
	$ = jQuery
  
	var defaultUserEmail = $("#user_email").attr('value');
	var defaultUserPassword = $("#user_password").attr('value');

	$("#user_email").click(function(){
		if ($(this).attr('value').length > 0 && $(this).attr('value') == defaultUserEmail){
			$(this).attr('value', '');
		}
	});
	
	$("#user_email").blur(function(){
		if ($(this).attr('value').length == 0){
			$(this).attr('value', defaultUserEmail);
		}
	});
	
	$("#user_password").click(function(){
		if ($(this).attr('value').length > 0 && $(this).attr('value') == defaultUserPassword){
			$(this).attr('value', '');
		}
	});
	
	$("#user_password").blur(function(){
		if ($(this).attr('value').length == 0){
			$(this).attr('value', defaultUserPassword);
		}
	}); 

});