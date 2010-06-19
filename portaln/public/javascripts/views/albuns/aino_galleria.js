jQuery(document).ready(function(){
    $ = jQuery;               
    //Galleria.loadTheme('/aino_galleria_themes/fullscreen/galleria.fullscreen.js');
		Galleria.loadTheme('/aino_galleria_themes/classic/galleria.classic.js');
		//Galleria.loadTheme('/aino_galleria_themes/lightbox/galleria.lightbox.js');
		$('.galeria').galleria({
			transition: 'fade',
			data_source: '.galeria',
			keep_source: false,
			height: 800
		});
		
		$('#load').css('display', 'none');
		$('#fotos').fadeIn();
		
});