class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.float :latitude
      t.float :longitude
      t.references :branch, index: true

      t.timestamps
    end
  end
end
