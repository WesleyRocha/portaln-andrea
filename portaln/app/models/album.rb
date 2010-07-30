class Album < ActiveRecord::Base
  include Workflow
  include PortalN::Searchable 
  include PortalN::Converters

  set_table_name :albuns
          
  acts_as_taggable   
  belongs_to :user
  
  has_many :fotos, 
           :order => 'ordem asc',
           :dependent => :delete_all
           
  has_many :fotos_publicadas, 
           :conditions => ["publicada = ?", true], 
           :order => 'ordem asc', 
           :class_name => 'Foto'
                             
  alias_column :original => 'user_id', :new => 'autor_id'
  alias_column_method :original => 'user', :new => 'autor'

  validates_presence_of :titulo, :user_id
  validates_uniqueness_of :titulo
  
  # ======================================================================
  # Criacao dos indices de pesquisa
  # ======================================================================

  # define_index do
  #   # fields
  #   indexes titulo
  #   indexes descricao
  #   indexes workflow_state
  #   has "workflow_state = 'publicado'", :as => :published, :type => :boolean
  #   #has published_at, :sortable => true, :type => :datetime
  #                                  
  #   # Isso ira permitir que novos dados sejam automaticamente indexados
  #   set_property :delta => :delayed
  #   set_property :enable_star => true
  #   set_property :min_prefix_len => 3
  # end
  
  # ======================================================================
  # Definicao da maquina de estados
  # ======================================================================
  
  workflow do
    state :novo do
      event :publicar, :transitions_to => :publicado do
        self.published_at = Time.now
      end
    end
    state :publicado do 
      event :tirar_do_ar, :transitions_to => :novo do
        self.published_at = nil
      end
    end
  end     
  
  # ======================================================================
  # Metodos do objeto
  # ======================================================================
             
  def to_param
    "#{self.id}-#{self.titulo.to_url}"
  end
             
  def tags_string
    tag_list.join(', ')
  end
  
  def capa
    if @capa then return @capa end
    
    # Se as fotos estivem ordenadas, retorna a primeiora
    @capa = Foto.find(:first, 
                     :conditions => ["album_id = ? and publicada = ? and ordem = ?", self.id, true, 0])
    if @capa then return @capa end                        
      
    # Caso nao estejam, retorna a primeira enviada 
    @capa = Foto.find(:first, 
              :conditions => ["album_id = ? and publicada = ?", self.id, true],
              :order => "created_at asc")
    @capa
  end
    
  # Esse metodo permite a sintaxe:
  # => album.recuperar_fotos(ids).publicar!
  #
  # Dessa forma um grupo de fotos pode ser recuperado e publicado, se necessario.
  #                                                  
  def recuperar_fotos(ids)
    # Caso passe um hash, assume que a chave eh o id
    if ids.class == Hash or ids.class.superclass == Hash then ids = ids.keys.collect {|id| Integer(id)} end
                
    album_id = self.id
    fotos = Foto.find(ids, :order => 'ordem asc')
                   
    # Cria um singleton object com as fotos, para poder criar o metodo apenas para essa instancia
    metaclass = class << fotos; self; end 
                                                                                                 
    # Cria o metodo publicar! apenas nessa instancia do objeto fotos
    metaclass.send :define_method, :publicar! do
      fotos_id = fotos.collect{|f| f.id} 
      Foto.update_all("publicada = true", ["id in (?) and album_id = ?", fotos_id, album_id])
    end
    
    metaclass.send :define_method, :tirar_do_ar! do
      fotos_id = fotos.collect{|f| f.id} 
      Foto.update_all("publicada = false", ["id in (?) and album_id = ?", fotos_id, album_id])
    end

    fotos
  end
  
  # ======================================================================
  # Metodos da classe
  # ======================================================================
  
  def self.pesquisa_paginada(params = {})      
    # Remove, caso exista, do hash para evitar pesquisar por page_size que nao eh uma coluna do banco                      
    page_size = params.delete :page_size         
    
    # Caso o tamanho da pagina seja informado e atenda as seguintes condicoes:
    # => Menor que PortalN::PAGE_SIZE
    # => Maior que 0
    # Ele sera definido no lugar do valor padrao.
    page_condition = (page_size and page_size.to_i < PortalN::PAGE_SIZE and page_size.to_i > 0)
    page_size = page_condition ? page_size.to_i : PortalN::PAGE_SIZE
    
    # Garante que sempre pesquisara nas noticias publicadas, a menos que o status
    # seja informado
    unless params[:workflow_state] then params[:workflow_state] = 'publicado' end
    
    # somente inclui as tabelas e condicoes de tag caso seja requisitado  
    if params[:tag]
      joins = Album.tag_join
      params[:tag] = Album.tag_query(params[:tag])
    end
    
    nsearch(
      {
        :select => "#{Album.table_name}.*",
        :params => params,
        :joins => joins,
        :order => (params[:workflow_state] == 'novo') ? 'created_at desc' : 'published_at desc'
      },
      page_size
    )
  end
  
  private
  def self.tag_join
    [
      "JOIN #{Tagging.table_name} ON #{Tagging.table_name}.taggable_type = '#{Album.to_s}'",
      "JOIN #{Tag.table_name} ON #{Tag.table_name}.id = #{Tagging.table_name}.tag_id"
    ]
  end
  
  def self.tag_query(tag)
    {
      :query => %Q{
        lower(#{Tag.table_name}.name) = lower(?)
        and
        #{Tagging.table_name}.tag_id = #{Tag.table_name}.id
        and
        #{Tagging.table_name}.taggable_id = #{Album.table_name}.id  
      },
      :value => tag
    }
  end
  
end





































