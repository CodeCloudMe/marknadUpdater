class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :description
      t.string :price
      t.string :company
      t.string :link

      t.timestamps
    end
  end
end
