jQuery(document).ready(function(){
	$ = jQuery                          
	
	/* ********************************************************************
	 * Adiciona o auto-complete das tags
	 */             
	$("#tag_name").autocomplete({
		minLength: 2,
	  source: function(request, response) {
		  $.ajax({
				url: '/tag/find/' + request.term,
				dataType: "json",
				success: function (data, status) {
					response(
						$.map(data, function(item) {
						  return {
							  label: item.tag.name,
								value: item.tag.name
							}
						})
					) //response
				}
			})				
		}
	});
	
	/* ********************************************************************
	 * Adiciona o click para adicionar a tag
	 */
	$('#adicionar_tag').click(function(){
	  var value = $('#tag_name').attr('value');
		if ($.trim(value) != '') {
			var ja_existe = false;
			$('#tag_container .tag_added input[name="tags[]"]').each(function(){
			  if ($(this).attr('value') == value) {
			    ja_existe = true;
			    return;
			  }
			});
		  
			// Somente adiciona se ainda nao tiver
		  if (ja_existe == false) {
				$('<div class="tag_added"><input type="hidden" value="'+value+'" name="tags[]"><span class="tag">'+value+'</span><span class="remove clicavel"></span></div>').appendTo($('#tag_container'));
			}
			
			$('#tag_name').attr('value', '');
		}
		
		// Uma vez que a tag eh adicionada, adiciona-se a caracteristica de remove-la.
		adicionarCaracteristicaRemoverTags();
		
		return false;
	});                                             
	
	adicionarCaracteristicaRemoverTags();
	
});

/* ********************************************************************
 * Adiciona a funcao de remover as tags
 */                                    
function adicionarCaracteristicaRemoverTags() {
	 $('#tag_container .tag_added').each(function(){
	   var tag = $(this);
		 $('.remove', this).click(function(){
		   tag.remove();
	 	 });
	 });
}