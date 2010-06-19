jQuery(document).ready(function(){
    $ = jQuery;
		
		$('.foto_thumb').corner('15px');
		$('.foto_thumb2').corner('15px');
    
		// initialize tooltip
		$("a .descricao").tooltip({

		   // tweak the position
		   offset: [10, 2],

		   // use the "slide" effect
		   effect: 'slide',
		
			 position: 'center right'

		// add dynamic plugin with optional configuration for bottom edge
		}).dynamic({ bottom: { direction: 'down', bounce: true } });
		
});