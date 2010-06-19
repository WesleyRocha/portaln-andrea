jQuery(document).ready(function(){
	$ = jQuery
                                                      
	/*
	 * Adiciona o funcao de click na ancora (a) #search
	 */
	$('#busca-padrao #search').click(function(){
		 var value = $('#busca-padrao #query').attr('value');
		 if (value.length > 0) {
		 	 $(this).attr('href', '/pesquisar/' + value);
		   return true;           
		 }
		 return false;
	});
	                                
	/*
	 * Dispara a pesquisa quando a tecla ENTER eh precionada no campo #query
	 */                   
	$('#busca-padrao #query').keypress(function(event){
		//wich eh pra funcionar no IE. 13 = ENTER
		var condition = (
			((event.which && event.which == 13) || (event.keyCode && event.keyCode == 13))
			&& $(this).attr('value').length > 0
		);
		    
		if (condition) {
			document.location = '/pesquisar/' + $(this).attr('value');
		}
	});
	
});