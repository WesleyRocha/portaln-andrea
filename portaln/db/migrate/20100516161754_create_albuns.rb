class CreateAlbuns < ActiveRecord::Migration
  def self.up          
    create_table :albuns do |t|
      t.string :titulo
      t.text :descricao
                        
      t.string :workflow_state
      t.belongs_to :user
      
      t.timestamp :published_at
      t.boolean :delta, :default => true, :null => false
      t.timestamps             
    end
    
    add_index :albuns, :titulo, :unique => true
  end

  def self.down
    drop_table :albuns
  end
end
