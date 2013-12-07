class FixRailwayAttributes < ActiveRecord::Migration
  def self.up
    rename_column :railways, :abreviation, :abbreviation
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
