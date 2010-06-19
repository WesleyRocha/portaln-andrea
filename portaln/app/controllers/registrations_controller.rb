class RegistrationsController < ApplicationController
                
  before_filter :authenticate_user!
  before_filter :only => [:create, :new, :index] do |controller|
    # Lanca Aegis::PermissionError caso nao possa
    controller.current_user.may_criar_usuarios!
  end
                                               
  def index
    @users = User.pesquisa_paginada
  end
  
  def new
    @user = User.new
  end

  # POST /resource/sign_up
  def create
    @user = User.new params[:user]
     if @user.save
       flash[:notice] = I18n.t("devise.registrations.signed_up")
       #sign_in_and_redirect('user', @user)
       redirect_to :controller => :registrations, :action => :index
     else
       clean_up_passwords(@user)
       render :new
     end
  end

  # GET /resource/edit
  def edit   
    if current_user
      @user = current_user
    else
      redirect_to root_path
    end
  end

  # PUT /resource
  def update                       
    # Garante que um usuario comum nao consiga mudar seu role_name
    unless current_user.may_criar_usuarios?
      params[:user][:role_name] = Permissions::OPERADOR
    end
    
    if current_user.update_with_password(params[:user])
      flash[:notice] = I18n.t("devise.registrations.updated")
      redirect_to after_sign_in_path_for(current_user)
    else
      clean_up_passwords(current_user)
      @user = current_user
      render :edit
    end
  end

  protected
  def clean_up_passwords(object)
    object.clean_up_passwords if object.respond_to?(:clean_up_passwords)
  end
end
