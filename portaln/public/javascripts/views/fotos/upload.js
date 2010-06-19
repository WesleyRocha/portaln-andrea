jQuery(document).ready(function(){
    $ = jQuery;                

		/* ************************************************************************
		 * Habilita a ordenacao para as fotos carregadas
		 */
		$('#lista_fotos_carregadas').sortable();

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
      fileDataName  : 'foto[imagem]',
      script        : $('.upload #controller_path').attr('value'),
			scriptData    : {
				'session_name': session_name,
				'session_key' : session_value
			},
      onAllComplete : function(event, data){ 
         var controllerURL = $('.upload #recarregar_imagens_path').attr('value');
				 recarregar_imagens(controllerURL);
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
		 * Adiciona a caracteristica de selecionar todos no checkbox selecionar todos
		 */
		$('#selecionar_todos').click(function(e){
			 e.preventDefault();
			 if($('#hidden_check').attr('checked') == false){
					$(':checkbox').attr('checked', '');
					$('#hidden_check').attr('checked', 'checked');
			 } else {
				  $(':checkbox').attr('checked', 'checked');
					$('#hidden_check').attr('checked', '');
			 }
		});     
		
		/* ************************************************************************
		 * Adiciona o submit no botao de publicar
		 */
		$('#publicar_fotos').click(function(e){
			 e.preventDefault();
			 $('#form_imgs').attr('action', $('.upload #opcoes #url_publicar').attr('value'));  
			 $('#form_imgs').submit();			
		});
		
		/* ************************************************************************
		 * Adiciona o submit no botao de tirar do ar
		 */
		$('#tirar_do_ar').click(function(e){
			 e.preventDefault();
			 $('#form_imgs').attr('action', $('.upload #opcoes #url_tirar_do_ar').attr('value'));  
			 $('#form_imgs').submit();			
		});                                                                  
		                                            
		/* ************************************************************************
		 * Adiciona o submit no botao de salvar odenacao
		 */
		$('#salvar_ordenacao').click(function(e){                 
 			 e.preventDefault();
			 $('#lista_fotos_carregadas li').each(function(index){
				 var campo = $('<input type="hidden" name="ordem[' + $(this).attr('id') + ']" value="'+ index  +'">');
				 campo.appendTo($('#form_imgs'));
			 });                               
			 
			 $(':checkbox').attr('checked', '');
			 $('#form_imgs').attr('action', $('#url_salvar_ordenacao').attr('value'));
			 $('#form_imgs').submit();
		});
		
		/* ************************************************************************
		 * Adiciona o submit no botao de editar legendas
		 */
		$('#editar_legendas').click(function(e){
			 e.preventDefault();
			 $('#form_imgs').attr('action', $('.upload #opcoes #url_editar_legendas').attr('value'));  
			 $('#form_imgs').submit();			
		});                                                                  
		
});

/* ************************************************************************
 * Funcao de callback do upload. Recarrega a lista de imagens.
 */
function recarregar_imagens(url){
	var loadIcon = $('.upload #load_icon_path').attr('value');
	loadIcon = "<img src='" + loadIcon + "' alt='load'/>";
	
	var loadText = $('.upload #load_text').attr('value');
	var loadElement = $(loadIcon + "&nbsp;<span class='load'>" + loadText + "</span>");
	
	$.ajax({
		 url: url,
		 dataType: 'html',
		 type: 'GET',
		 beforeSend: function(){
				$('.upload #lista_fotos').html(loadElement);
		 },
		 success: function(data, textStatus){
			  $('.upload #fotos_container').hide();  
			  $('.upload #opcoes').css('display', 'inline');
				$('.upload #lista_fotos').html(data);
				$('#lista_fotos_carregadas').sortable();
				$('.upload #fotos_container').fadeIn('slow');
		 }
	});
}