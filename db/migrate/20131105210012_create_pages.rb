class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :id
      t.string :name
      t.string :picture

      t.timestamps
    end
  end
end
