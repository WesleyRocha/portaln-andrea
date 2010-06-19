require 'spec_helper'

describe TagsController do
  include Devise::TestHelpers
  
  it "deveria pesquisa a tag pelo trecho informado" do
    sign_in users(:test) # So permito essa consulta para usuarios logados.
    
    tag = Factory.create :tag
    get :find, :name => tag.name
    response.should be_success
    response.body.should == Tag.find(
      :all, 
      :conditions => ["lower(name) like lower(?)", "%#{tag.name}%"], 
      :order => 'name asc'
    ).to_json
  end        
  
  it "deveria carregar a contagem das tags para montar um tagcloud" do
    Factory.create :tag, :name => 'tag1'
    Factory.create :tag, :name => 'tag2'
    
    get :cloud_noticia
    response.should be_success
    assigns[:tags].should_not be_nil
    assigns[:tags].member?('tag1')
    assigns[:tags].member?('tag2')
  end
  
end
