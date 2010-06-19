jQuery(document).ready(function(){
    $ = jQuery;

		$('#galleryview').galleryView({
				panel_width: 1024,
				panel_height: 640,
				frame_width: 110,
				frame_height: 110,
				
				nav_theme: 'light',
				transition_speed: 300,
				   
				pause_on_hover: true
		});
		
		$('#load').css('display', 'none');
		$('#fotos').fadeIn();

});