require 'spec_helper'

describe FotosController do
  include Devise::TestHelpers
  
  it "deveria salvar uma foto para um album" do
    sign_in users(:test)

    count = Foto.count

    album = Factory.create :album, :user_id => users(:test).id
    hash = Factory.attributes_for :foto                                   
    
    post :create, :album_id => album.id, :foto => hash
    response.should be_success
    
    Foto.should have(count + 1).records
    assigns[:foto].should_not be_nil
    assigns[:foto].album_id.should == album.id
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id                  
  end

  it "nao deveria salvar uma foto para um album album que nao eh do usuario" do
    sign_in users(:test2)

    count = Foto.count

    album = Factory.create :album, :user_id => users(:test).id
    hash = Factory.attributes_for :foto                                   
    
    post :create, :album_id => album.id, :foto => hash
    response.should render_template("errors/forbidden")
    
    Foto.should have(count).records
    assigns[:foto].should be_nil
    assigns[:album].should be_nil
  end
                          
  it "nao deveria aceitar a salvar a foto sem usuario logado" do
    count = Foto.count

    album = Factory.create :album, :user_id => users(:test).id
    hash = Factory.attributes_for :foto                                   
    
    post :create, :album_id => album.id, :foto => hash
    response.should redirect_to('/users/login?unauthenticated=true')
    
    Foto.should have(count).records
    assigns[:foto].should be_nil
    assigns[:album].should be_nil
  end
             
  it "deveria carregar todas as fotos de um album especifico" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    5.times {Factory.create :foto, :album_id => album.id}                                   
                                            
    album2 = Factory.create :album, :titulo => 'album2', :user_id => users(:test).id
    2.times {Factory.create :foto, :album_id => album2.id}                                   
    
    get :all_by_album, :album_id => album.id
    response.should render_template('fotos/_lista_edicao')
    
    assigns[:album].should_not be_nil
    assigns[:fotos].should_not be_nil                 
    assigns[:album].id.should == album.id
    assigns[:fotos].length.should == 5
    assigns[:fotos].each {|f| f.album_id.should == album.id}
  end
  
  it "nao deveria permitir carregar as fotos de uma album de outro usuario" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    5.times {Factory.create :foto, :album_id => album.id}
    
    get :all_by_album, :album_id => album.id
    response.should render_template("errors/forbidden")
    
    assigns[:album].should be_nil
    assigns[:fotos].should be_nil                 
  end  
  
  it "deveria permitir publicar as fotos de um album" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    5.times {Factory.create :foto, :album_id => album.id} 
                                        
    fotos = album.fotos      
    fotos.each {|f| f.publicada.should be_false}
                             
    ids = fotos.collect{|f| f.id}
    
    post :publicar, :album_id => album.id, :fotos => ids
    response.should redirect_to("/albuns/#{album.id}/edit")
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.fotos.publicadas')       
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    
    album.reload.fotos.each {|f| f.publicada.should be_true}
  end
                               
  it "nao deveria permitir publicar as fotos de outro usuario" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    5.times {Factory.create :foto, :album_id => album.id} 
                                        
    fotos = album.fotos      
    fotos.each {|f| f.publicada.should be_false}
                             
    ids = fotos.collect{|f| f.id}
    
    post :publicar, :album_id => album.id, :fotos => ids
    response.should render_template("errors/forbidden")
    
    assigns[:album].should be_nil
    
    album.reload.fotos.each {|f| f.publicada.should be_false}
  end                                       
  
  it "deveria validar o envio de pelo menos uma foto para publicar" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    
    post :publicar, :album_id => album.id
    response.should redirect_to("/albuns/#{album.id}/edit")
    response.flash[:error].should == I18n.t('portaln.albuns.erros.pelo_menos_uma')       
  end

  it "deveria permitir tirar do ar as fotos de um album" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    5.times {Factory.create :foto, :album_id => album.id, :publicada => true} 
                                        
    fotos = album.fotos      
    fotos.each {|f| f.publicada?.should be_true}
                             
    ids = fotos.collect{|f| f.id}
    
    post :tirar_do_ar, :album_id => album.id, :fotos => ids
    response.should redirect_to("/albuns/#{album.id}/edit")
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.fotos.fora_do_ar')       
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    
    album.reload.fotos.each {|f| f.publicada?.should be_false}
  end
                               
  it "nao deveria permitir tirar do ar as fotos de outro usuario" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    5.times {Factory.create :foto, :album_id => album.id, :publicada => true} 
                                        
    fotos = album.fotos      
    fotos.each {|f| f.publicada?.should be_true}
                             
    ids = fotos.collect{|f| f.id}
    
    post :tirar_do_ar, :album_id => album.id, :fotos => ids
    response.should render_template("errors/forbidden")
    
    assigns[:album].should be_nil
    
    album.reload.fotos.each {|f| f.publicada?.should be_true}
  end                                       
  
  it "deveria validar o envio de pelo menos uma foto para tirar do ar" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    
    post :tirar_do_ar, :album_id => album.id
    response.should redirect_to("/albuns/#{album.id}/edit")
    response.flash[:error].should == I18n.t('portaln.albuns.erros.pelo_menos_uma')       
  end           
  
  it "deveria salvar a ordem das fotos" do
    sign_in users(:test)
    album = Factory.create :album, :user_id => users(:test).id

    ordem = {}               
    num = 0
    5.times do
      foto = Factory.create :foto, :album_id => album.id
      ordem["#{foto.id}"] = num
      num += 1
    end 
    
    ids = album.fotos.collect {|foto| foto.id}
                                             
    post :salvar_ordem, :album_id => album.id, :ordem => ordem
    response.should redirect_to("/albuns/#{album.id}/edit")
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.fotos.ordenadas')
             
    # Verificando a ordem normal 0, 1, 2, etc                                    
    num = 0
    album.reload.fotos.each do |foto|
      foto.ordem.should == num
      num += 1
    end
                                                                
    # Preparando o teste para verificar a ordem contraria 2, 1, 0
    num = 0
    album.fotos.reverse.each do |foto|
      ordem["#{foto.id}"] = num
      num += 1
    end

    post :salvar_ordem, :album_id => album.id, :ordem => ordem
    response.should redirect_to("/albuns/#{album.id}/edit")
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.fotos.ordenadas')
                                        
    num = 0
    album.reload.fotos.each do |foto|  
      foto.ordem.should == num
      num += 1
    end
  end              
  
  it "nao deveria permitir salvar ordem para as fotos de outro usuario" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    
    ordem = {}               
    num = 0
    5.times do
      foto = Factory.create :foto, :album_id => album.id
      ordem["#{foto.id}"] = num
      num += 1
    end 
                                        
    post :salvar_ordem, :album_id => album.id, :ordem => ordem
    response.should render_template("errors/forbidden")
    
    assigns[:album].should be_nil
    album.reload.fotos {|f| f.ordem.should be_nil}
  end                                       
                                   
  it "deveria apagar uma foto" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    
    album.fotos.length.should == 1
    delete :destroy, :id => foto.id, :album_id => album.id
    response.should redirect_to "/albuns/#{album.id}/edit"
                              
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.fotos.removida')
    album.reload.fotos.length.should == 0
  end                                                     
  
  it "nao deveria permitir apagar uma foto do album de outra pessoa" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    foto = Factory.create :foto, :album_id => album.id
    
    album.fotos.length.should == 1
    delete :destroy, :id => foto.id, :album_id => album.id
    response.should render_template("errors/forbidden")
                              
    assigns[:album].should be_nil
    album.reload.fotos.length.should == 1
  end     
  
  it "deveria carregar o formulario das legendas para criacao ou edicao" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    
    get :carregar_legendas, :album_id => album.id, :fotos => [foto.id]
    response.should be_success
    response.should render_template('carregar_legendas.html.erb')
    
    assigns[:album].should_not be_nil
    assigns[:album].id.should == album.id
    assigns[:fotos].should_not be_nil
    assigns[:fotos].first.id.should == foto.id
  end
  
  it "nao deveria permitir carregar as legendas do album de outro usuario" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    foto = Factory.create :foto, :album_id => album.id
    
    get :carregar_legendas, :album_id => album.id, :fotos => [foto.id]
    response.should render_template("errors/forbidden")
    
    assigns[:album].should be_nil
    assigns[:fotos].should be_nil
  end
  
  it "nao deveria permitir carregar as legendas sem fotos selecionadas" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    
    get :carregar_legendas, :album_id => album.id
    response.should redirect_to "/albuns/#{album.id}/edit"
    response.flash[:error].should == I18n.t('portaln.albuns.erros.pelo_menos_uma')       
  end
  
  it "deveria permitir salvar ou editar as legendas de varias fotos" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    
    post :salvar_legendas, :album_id => album.id, :fotos => [[foto.id, {:legenda => "legenda", :fotografo => "Tulio"}]]
    response.should redirect_to "/albuns/#{album.id}/edit"
    
    response.flash[:notice].should == I18n.t('portaln.albuns.mensagens.fotos.editar_legendas')
    
    assigns[:album].should_not be_nil
    
    foto.reload.fotografo.should_not be_nil
    foto.fotografo.should == "Tulio"
    foto.legenda.should_not be_nil
    foto.legenda.should == "legenda"
  end
  
  it "nao deveria permitir salvar legendas para o album de outro usuario" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test2).id
    foto = Factory.create :foto, :album_id => album.id, :fotografo => nil, :legenda => nil
    
    post :salvar_legendas, :album_id => album.id, :fotos => [[foto.id, {:legenda => "legenda", :fotografo => "Tulio"}]]
    response.should render_template("errors/forbidden")
    
    foto.reload.fotografo.should be_nil
    foto.legenda.should be_nil
  end                  
  
  it "deveria carregar a imagem pelo metodo de controller" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    album.recuperar_fotos([foto.id]).publicar!
    
    get :show, :id => foto.id               
    response.should be_success
    
    assigns[:foto].should_not be_nil
    assigns[:foto].id.should == foto.id
    assigns[:style].should == 'normal'
  end
  
  it "deveria carregar imagem nao publicada apenas para o dono" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    
    get :show, :id => foto.id               
    response.should be_success
    
    assigns[:foto].should_not be_nil
    assigns[:foto].id.should == foto.id
    assigns[:style].should == 'normal'
  end
             
  it "deveria permitir que usuarios nao autenticados acessem as fotos publicadas" do
    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    album.recuperar_fotos([foto.id]).publicar!
    
    get :show, :id => foto.id               
    response.should be_success
    
    assigns[:foto].should_not be_nil
    assigns[:foto].id.should == foto.id
    assigns[:style].should == 'normal'
  end
  
  it "deveria carregar a imagem em outro style caso informado" do
    sign_in users(:test)

    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    album.recuperar_fotos([foto.id]).publicar!
    
    get :show, :id => foto.id, :style => 'thumb'               
    response.should be_success
    
    assigns[:foto].should_not be_nil
    assigns[:foto].id.should == foto.id
    assigns[:style].should == 'thumb'
    
    get :show, :id => foto.id, :style => 'thumb2'               
    response.should be_success
    
    assigns[:foto].should_not be_nil
    assigns[:foto].id.should == foto.id
    assigns[:style].should == 'thumb2'
    
    get :show, :id => foto.id, :style => 'grande'               
    response.should be_success
    
    assigns[:foto].should_not be_nil
    assigns[:foto].id.should == foto.id
    assigns[:style].should == 'grande'
  end
  
  it "nao deveria permitir carregar fotos nao publicadas" do
    album = Factory.create :album, :user_id => users(:test).id
    foto = Factory.create :foto, :album_id => album.id
    
    get :show, :id => foto.id
    response.should_not be_success
  end
  
end  































