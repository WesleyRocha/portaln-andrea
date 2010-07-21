# = Noticia
# == Atributos
# * string :titulo
# * text :conteudo
# * text :resumo    
# * BelongsTo: user
# * timestamp :created_at
# * timestamp :updated_at
#
class Noticia < ActiveRecord::Base
  include Workflow
  include PortalN::Searchable 
  include PortalN::Converters
     
  acts_as_taggable
  belongs_to :user
  has_many :anexos, :order => 'created_at asc'

  alias_column :original => 'user_id', :new => 'autor_id'
  alias_column_method :original => 'user', :new => 'autor'
                
  act_as_virtual_date :created_at
  
  validates_presence_of :titulo, :conteudo, :user_id
  validates_uniqueness_of :titulo

  # ======================================================================
  # Criacao dos indices de pesquisa
  # ======================================================================

  define_index do
    # fields
    indexes titulo
    indexes conteudo
    indexes workflow_state
    has "workflow_state = 'publicada'", :as => :published, :type => :boolean
                                   
    # Isso ira permitir que novos dados sejam automaticamente indexados
    set_property :delta => :delayed
    set_property :enable_star => true
    set_property :min_prefix_len => 3
  end
  
  # ======================================================================
  # Definicao da maquina de estados
  # ======================================================================
  
  workflow do
    state :nova do
      event :publicar, :transitions_to => :publicada do
        self.published_at = Time.now
      end
    end
    state :publicada
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
    unless params[:workflow_state] then params[:workflow_state] = 'publicada' end
    
    # somente inclui as tabelas e condicoes de tag caso seja requisitado  
    if params[:tag]
      joins = Noticia.tag_join
      params[:tag] = Noticia.tag_query(params[:tag])
    end
    
    nsearch(
      {
        :select => "#{Noticia.table_name}.*",
        :params => params,
        :joins => joins,
        :order => (params[:workflow_state] == 'nova') ? 'created_at desc' : 'published_at desc'
      },
      page_size
    )
  end
  
  private
  def self.tag_join
    [
      "JOIN #{Tagging.table_name} ON #{Tagging.table_name}.taggable_type = '#{Noticia.to_s}'",
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
        #{Tagging.table_name}.taggable_id = #{Noticia.table_name}.id  
      },
      :value => tag
    }
  end
end  
























