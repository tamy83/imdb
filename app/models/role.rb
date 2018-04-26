class Role < ActiveRecord::Base

  validates :name, presence: true

#  attr_accessor :name

end
