class CreateConfiguracoes < ActiveRecord::Migration
  def self.up
    create_table :configuracoes do |t|
      
      t.belongs_to :quem_alterou, :class_name => 'User'
      t.text :contato
      t.string :email
      
      t.timestamps
    end
  end

  def self.down
    drop_table :configuracoes
  end
end
