require 'spec_helper'

describe Noticia do

  it "deveria salvar" do
    count = Noticia.count
    Noticia.should have(count).records
    
    n = Noticia.new(:titulo => 'Titulo',
                    :resumo => 'Resumo',
                    :conteudo => 'Conteudo',
                    :user => users(:test))
    n.save.should be_true        
    
    Noticia.should have(count + 1).records
  end
  
  it "deveria validar os campos obrigatorios" do
    n = Noticia.new
    n.save.should be_false
    
    n.errors.should_not be_nil               
    n.should have(1).errors_on(:conteudo)
    n.should have(1).errors_on(:titulo)
    n.should have(1).errors_on(:user_id)
    n.should have(0).errors_on(:resumo)
  end
  
  it "to_param deveria retorna id-titulo" do
    noticia = Factory.create :noticia
    noticia.to_param.should == "#{noticia.id}-#{noticia.titulo.to_url}"
  end
                      
  it "deveria aceitar tags" do
    noticia = Factory.create :noticia
    noticia.save.should be_true        
    noticia.tag_list.length.should == 0
    
    noticia.tag_list = ["tag1", "tag2", "tag3"]
    noticia.save.should be_true
    
    noticia.reload
    noticia.tag_list.should_not be_nil
    noticia.tag_list.length.should == 3
  end       
  
  it "deveria estar no estado nova quando criado" do
    noticia = Factory.create :noticia
    noticia.save.should be_true  
    
    noticia.reload
    noticia.nova?.should be_true
    noticia.workflow_state.should == "nova"
  end          
                    
  it "deveria permitir publicar" do
    noticia = Factory.create :noticia
    noticia.save.should be_true  
    noticia.nova?.should be_true

    noticia.publicar!

    noticia.reload
    noticia.publicada?.should be_true
    noticia.workflow_state.should == "publicada"
  end
  
  it "deveria adicionar a data de publicacao no ato de publicar" do
    noticia = Factory.create :noticia, :titulo => 'Noticia de teste'
    noticia.nova?.should be_true
    noticia.published_at.should be_nil                 
    
    noticia.publicar!                 
    noticia.published_at.should_not be_nil
  end
  
  it "deveria realizar uma pesquisa paginada em qualquer status" do
    # Noticias nao publicadas (novas)
    (1..10).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo novas #{number}")
    end
                                    
    # Noticias publicadas
    (1..10).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicadas #{number}", :workflow_state => 'publicada')
    end
           
    # Pesquisa pelas publicadas
    noticias = Noticia.pesquisa_paginada
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE
                               
    # Pesquisa pelas novas            
    noticias = Noticia.pesquisa_paginada(:workflow_state => 'nova')
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE
  end
  
  it "deveria realizar uma pesquisa paginada apenas em noticias publicadas" do
    # Noticias nao publicadas (novas)
    (1...10).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo novas #{number}")
    end
                                    
    # Noticias publicadas
    (1...22).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicadas #{number}", :workflow_state => 'publicada')
    end
    
    noticias = Noticia.pesquisa_paginada
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE
    
    noticias = Noticia.pesquisa_paginada(:page => 2)
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE
    
    noticias = Noticia.pesquisa_paginada(:page => 3)
    noticias.should_not be_nil
    noticias.length.should < PortalN::PAGE_SIZE
  end

  it "deveria poder definir o tamanho da pagina na pesquisa paginada" do
    # Noticias nao publicadas (novas)
    (1...10).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo novas #{number}")
    end
                                    
    # Noticias publicadas
    (1...22).each do |number| 
      Factory.create(:noticia, :titulo => "Titulo publicadas #{number}", :workflow_state => 'publicada')
    end
                                                                    
    # Sem informar utiliza PortalN::PAGE_SIZE
    noticias = Noticia.pesquisa_paginada
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE
                                             
    # Informando um valor < PortalN::PAGE_SIZE e > 0
    noticias = Noticia.pesquisa_paginada(:page_size => 1)
    noticias.should_not be_nil
    noticias.length.should == 1
                                                    
    # Valores maiores que PortalN::PAGE_SIZE retornam PortalN::PAGE_SIZE
    noticias = Noticia.pesquisa_paginada(:page_size => 100000)
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE              
                                                                        
    # Valores < 1 retornam PortalN::PAGE_SIZE
    noticias = Noticia.pesquisa_paginada(:page_size => 0)
    noticias.should_not be_nil
    noticias.length.should == PortalN::PAGE_SIZE              
  end
  
  
  it "deveria realizar uma pesquisa paginada pela tag" do
    n1 = Factory.create :noticia, :titulo => 'Titulo tag 1'
    n1.tag_list = ['tag1'] 
    n1.save!
    
    n2 = Factory.create :noticia, :titulo => 'Titulo tag 2'
    n2.tag_list = ['tag2'] 
    n2.save!
    
    n3 = Factory.create :noticia, :titulo => 'Titulo tag 3', :workflow_state => 'publicada'
    n3.tag_list = ['tag3'] 
    n3.save!
                        
    noticias = Noticia.pesquisa_paginada({
      :workflow_state => 'nova',
      :tag => 'tag1'
    })         
    noticias.should_not be_nil
    noticias.length.should > 0
    noticias[0].id.should == n1.id
    
    noticias = Noticia.pesquisa_paginada({
      :workflow_state => 'nova',
      :tag => 'tag2'
    })         
    noticias.should_not be_nil
    noticias.length.should > 0
    noticias[0].id.should == n2.id
    
    noticias = Noticia.pesquisa_paginada({
      :tag => 'tag3'
    })         
    noticias.should_not be_nil
    noticias.length.should > 0
    noticias[0].id.should == n3.id
                               
    noticias = Noticia.pesquisa_paginada({
      :tag => 'tag_desconhecida'
    })         
    noticias.should_not be_nil
    noticias.length.should == 0
  end
  
end
  

























