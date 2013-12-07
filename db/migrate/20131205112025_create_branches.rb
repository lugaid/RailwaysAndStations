class CreateBranches < ActiveRecord::Migration
  def change
    create_table :branches do |t|
      t.string :description
      t.references :railway, index: true

      t.timestamps
    end
  end
end
