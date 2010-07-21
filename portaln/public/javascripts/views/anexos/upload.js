jQuery(document).ready(function(){
    $ = jQuery;

		/* ************************************************************************
		 * Criar estrutura de upload
		 */        
		var session_name = $('.upload #session_key_name').attr('value');
		var session_value = $('.upload #session_key_value').attr('value');
		
    $('#upload_files').uploadify({
      uploader      : $('.upload #uploadify_path').attr('value'),
      cancelImg     : $('.upload #img_cancel_path').attr('value'),
      multi         : true,
      queueID       : 'fileQueue',
      buttonText    : $('.upload #button_text').attr('value'),
      fileDataName  : 'anexo[arquivo]',
      script        : $('.upload #controller_path').attr('value'),
			scriptData    : {
				'session_name': session_name,
				'session_key' : session_value
			},
      onAllComplete : function(event, data){ 
         var controllerURL = $('.upload #recarregar_anexos_path').attr('value');
				 recarregar_anexos(controllerURL);
      }
    });                      
       
		/* ************************************************************************
		 * Adicionar funcao de upload no click do botao
		 */
		$('#link_upload').click(function(e){
			 e.preventDefault();
			 $('#upload_files').uploadifyUpload();
		});
		  
		/* ************************************************************************
		 * Adicionar funcao de limpar queue
		 */
		$('#link_clear').click(function(e){
			 e.preventDefault();
			$('#upload_files').uploadifyClearQueue();
		});
		                       
		/* ************************************************************************
		 * Adiciona caracteristica de selecao do conteudo ao campo na funcao de click
		 */
		$('.selecionar_ao_clicar').each(function(){
			var textfield = $(this);
			textfield.click(function(){
				textfield.select();
			})
		});

});

/* ************************************************************************
 * Funcao de callback do upload. Recarrega a lista de anexos.
 */
function recarregar_anexos(url){
	var loadIcon = $('.upload #load_icon_path').attr('value');
	loadIcon = "<img src='" + loadIcon + "' alt='load'/>";
	
	var loadText = $('.upload #load_text').attr('value');
	var loadElement = $(loadIcon + "&nbsp;<span class='load'>" + loadText + "</span>");
	
	$.ajax({
		 url: url,
		 dataType: 'html',
		 type: 'GET',
		 beforeSend: function(){
				$('.upload #lista_anexos').html(loadElement);
		 },
		 success: function(data, textStatus){
			  $('.upload #anexos_container').hide();  
				$('.upload #lista_anexos').html(data);
				$('.upload #anexos_container').fadeIn('slow');
		 }
	});
}