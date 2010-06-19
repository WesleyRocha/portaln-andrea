class Configuracao < ActiveRecord::Base
  
  belongs_to :quem_alterou, :class_name => 'User'
  
  validates_presence_of :quem_alterou_id
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}\Z)/
  
end
