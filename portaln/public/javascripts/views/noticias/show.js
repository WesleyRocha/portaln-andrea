jQuery(document).ready(function(){
	$ = jQuery
  
  /*
   * Adiciona em todos os links publicar o envio via ajax.
	 */
  $('.noticia').each(function(){
		
		var context = this;
		
		var noticia_id = $('#noticia_id', context).attr('value');
		var link = $('#publicar', context);
		var href = link.attr('href');
		
		link.click(function(){
			 if (confirm('Você tem certeza?')) {
			   
				 var loading = $('#load').html();
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
	
	/*
	 * Adiciona recursos de acessibilidade
	 */                                   
	 $("#font_size #up").fontscale(".view","up",{
		 unit: "percent",
		 increment: 20
	 });
	 $("#font_size #down").fontscale(".view","down",{
		 unit: "percent",
		 increment: 20
	 });
	 $("#font_size #reset").fontscale(".view","reset");

	 
});          






























