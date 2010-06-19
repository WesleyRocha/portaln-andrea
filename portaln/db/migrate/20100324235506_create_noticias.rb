class CreateNoticias < ActiveRecord::Migration
  def self.up
    create_table :noticias do |t|
      t.string :titulo
      t.text :conteudo
      t.text :resumo
                        
      t.string :workflow_state
      t.belongs_to :user
      
      t.timestamp :published_at
      t.boolean :delta, :default => true, :null => false
      t.timestamps             
    end
    
    add_index :noticias, :titulo, :unique => true
  end

  def self.down
    drop_table :noticias
  end
end
