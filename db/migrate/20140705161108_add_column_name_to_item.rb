class AddColumnNameToItem < ActiveRecord::Migration
  def change
    add_column :items, :photo_id, :string
  end
end
