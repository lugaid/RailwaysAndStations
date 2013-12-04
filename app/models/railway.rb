class Railway < ActiveRecord::Base
  has_many :points, dependent: :destroy
  accepts_nested_attributes_for :points, :reject_if => lambda { |a| a[:content].blank? }, :allow_destroy => true
end
