jQuery(document).ready(function(){
	$ = jQuery
  
  /*
   * Adiciona em todos os links publicar o envio via ajax.
	 */
  $('.noticias .noticia').each(function(){
		
		var context = this;
		
		var noticia_id = $('#noticia_id', context).attr('value');
		var link = $('#publicar', context);
		var href = link.attr('href');
		
		link.click(function(){
			 if (confirm('Você tem certeza?')) {
			   
				 var loading = $('.noticias #load').html();
				 $('#span_publicar', context).html(loading);
			   
			   $.ajax({
				   url: href,
					 dataType: 'html',
					 success: function (data, status) {
					   $('#span_publicar', context).html(data);   
					 }
			   }) 
			
			 }
			 return false;
		});
		
  });
	
});