class Railway < ActiveRecord::Base
  has_many :branches, dependent: :destroy
  accepts_nested_attributes_for :branches, :allow_destroy => true
  
  validates_presence_of :name
  validates_presence_of :abbreviation
  validates_presence_of :description
end
