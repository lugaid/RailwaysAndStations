class Branch < ActiveRecord::Base
  belongs_to :railway
  has_many :points, dependent: :destroy
  accepts_nested_attributes_for :points, :allow_destroy => true
  
  validates_presence_of :description
  validates_presence_of :color
end
