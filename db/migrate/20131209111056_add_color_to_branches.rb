class AddColorToBranches < ActiveRecord::Migration
  def change
    add_column :branches, :color, :string, limit: 10
  end
end
