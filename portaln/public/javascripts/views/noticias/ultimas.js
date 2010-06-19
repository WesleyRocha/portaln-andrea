jQuery(document).ready(function(){
	$ = jQuery
	
	/* ********************************************************************
	 * Carrega as últimas noticias
	 */                               
  $.ajax({
	  url: '/noticias/ultimas',
		dataType: "html",
		success: function (data, status) {
			$('#ultimas_noticias #ultimas_content #content_ultimas').html(data);
			$('#ultimas_noticias #load').hide();    
			$('#ultimas_noticias #clear_ultimas').hide();    
			$('#ultimas_noticias #feed_ultimas').show();    
			$('#ultimas_noticias #ultimas_content').fadeIn(200);
		}
	})
	
});