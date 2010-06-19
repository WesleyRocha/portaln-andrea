jQuery(document).ready(function(){
	$ = jQuery
	
	/* ********************************************************************
	 * Carrega a tag cloud de noticias
	 */                               
  $.ajax({
	  url: '/tag/cloud/noticias',
		dataType: "html",
		success: function (data, status) {
			$('#tag_cloud_noticia #tag_content #content_cloud').html(data);
			$('#tag_cloud_noticia #load').hide();
			$('#tag_cloud_noticia #tag_content').fadeIn(200);
		}
	})
	
});