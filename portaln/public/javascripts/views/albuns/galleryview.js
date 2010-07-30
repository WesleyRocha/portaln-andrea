jQuery(document).ready(function(){
    $ = jQuery;

		$('#galleryview').galleryView({
			  afterLoad: function(){
					$('#load').css('display', 'none');
					$('#fotos').fadeIn('fast');
			  },
				panel_width: 1099,
				panel_height: 640,
				frame_width: 110,
				frame_height: 90,
				//frame_width: 110,
				//frame_height: 110,
				
				nav_theme: 'light',
				transition_speed: 300,
				   
				pause_on_hover: true
		});
});