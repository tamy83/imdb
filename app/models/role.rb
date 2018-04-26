class Role < ActiveRecord::Base

  has_and_belongs_to_many :crew_members

  validates :name, presence: true

#  attr_accessor :name

end
