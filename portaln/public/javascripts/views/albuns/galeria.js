jQuery(document).ready(function(){
    $ = jQuery;

		$(".scrollable").scrollable({mousewheel: true});
            
		$(".items img").click(function() {
        trocar_imagem($(this));

		// Quando a pagina carregar, simula um click na primeira imagem
		}).filter(":first").click();

		var scrollable = $('.scrollable').data('scrollable');
		
		$(".galeria .proxima").click(function(){
			  proxima_imagem($(this), scrollable);
		});
		
		$(".galeria .anterior").click(function(){
			  imagem_anterior($(this), scrollable);
		});
		
		$('#load').css('display', 'none');
		$('#fotos').fadeIn();
		
});

function trocar_imagem(imagem) {
	// Verifica se nao eh o mesmo thumb que esta sendo clicado
	if (imagem.hasClass("active")) { return; }

	// Calcula a URL da imagem grande
	var url = imagem.attr("src").replace("thumb", "normal");

	// torna o elemento que encapsula a imagem transparente
	var wrap = $("#imagem_principal").fadeTo("fast", 0.1);

	var img = new Image();

	// Quando terminar de carregar a imagem chama essa funcao
	img.onload = function() {
		wrap.fadeTo("fast", 1);
		wrap.find("img").attr("src", url);
	};

	// Comeca a carregar a imagem
	img.src = url;

	// Ativa o thumb correspondente
	$(".items img").removeClass("active");
	imagem.addClass("active");
	
	$("#imagem_principal img").click(function() {
		$(this).expose({color: '#000000'});
	});                                             
	
	$("#imagem_principal img").addClass('clicavel');
	
}
                  
function get_imagem(indice) {
	var imagem = null;
	$(".items img").each(function(index){
	    if (index == indice) {
	        imagem = $(this);
	        return;    
	    }
	});           
	return imagem;
}

function mudar_imagem(elemento, indice, callback) {
	var imagem = get_imagem(indice);
	if (imagem != null) {
		trocar_imagem(imagem);
		callback(); 
	}
}
        
function proxima_imagem(elemento, scrollable) {
	var atual = scrollable.getIndex();
	mudar_imagem(elemento, atual + 1, function(){
		scrollable.next();
	});
}                                                                   

function imagem_anterior(elemento, scrollable) {
	var atual = scrollable.getIndex();
	mudar_imagem(elemento, atual - 1, function(){
		scrollable.prev();
	});
}



























