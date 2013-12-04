class CreateRailways < ActiveRecord::Migration
  def change
    create_table :railways do |t|
      t.string :name
      t.string :abreviation
      t.string :description

      t.timestamps
    end
  end
end
