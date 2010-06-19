require 'spec_helper'

describe PesquisaController do
  include Devise::TestHelpers
  
  it "deveria redirecionar para root_path em caso de query nil ou vazia" do
    get :index
    response.should redirect_to root_path
    response.flash[:error].should_not be_nil
    response.flash[:error].should == I18n.t("portaln.pesquisa.query_vazia")
    
    get :index, :query => ''
    response.should redirect_to root_path
    response.flash[:error].should_not be_nil
    response.flash[:error].should == I18n.t("portaln.pesquisa.query_vazia")
  end                                                                    
  
end