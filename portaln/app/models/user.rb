class User < ActiveRecord::Base
  include PortalN::Searchable
  include PortalN::Converters
  
  has_role :default => :operador
  
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable and :activatable
  # :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :username, :name, :role_name
                
  validates_presence_of :name, :username
  validates_uniqueness_of :username
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}\Z)/
  
  act_as_virtual_date :created_at
  
  def self.pesquisa_paginada(params = {})                            
    nsearch(
      {
        :select => "#{User.table_name}.*",
        :params => params,
        :order => 'created_at desc'
      },
      PortalN::PAGE_SIZE
    )
  end
  
end
