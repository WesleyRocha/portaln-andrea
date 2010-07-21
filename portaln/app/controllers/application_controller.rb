# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation
  
  rescue_from Aegis::PermissionError do |exception|
    
    output = ""
    output << "\n====================== Permissão Negada ======================\n"
    output << "\n\n#{DateTime.now.strftime("%d/%m/%Y %I:%M%p")} - Permissão negada\n"
    output << "Recurso acessado: #{request.url}\n"
    output << "Usuario:\n"
    if current_user
      output << "\tid: #{current_user.id} - username: #{current_user.username} - email: #{current_user.email}\n"
      output << "\tIp-atual: #{current_user.current_sign_in_ip} - Ip-anterior: #{current_user.last_sign_in_ip}\n"
    else                   
      output << "\tNao esta logado!\n"
      output << "\tIP: #{request.remote_ip}\n"
    end
    output << "\n====================== Permissão Negada ======================\n\n"
    
    logger.error output
    render :template => 'errors/forbidden', :locals => {:error => exception}
    return 
  end              
  
  def pesquisa_paginada(classe, status_permitido, params, workflow_state_condition = true)
    @tag = params[:tag]        
    
    if params[:workflow_state] and user_signed_in? and workflow_state_condition
      status = params[:workflow_state]
    else
      status = status_permitido
    end
    
    pesquisa = {
      :page => params[:page],   
      # Garante que so fara join com Tag caso necessario
      :tag => (@tag ? @tag : nil),                     
      
      # Garante que apenas usuarios logados pesquisem por outros status
      :workflow_state => status,
      :page_size => params[:page_size]
    }                                             

    classe.pesquisa_paginada(pesquisa)
  end
end
