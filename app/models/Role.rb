class Person < ActiveRecord::Base

  validates :name, presence: true

  def initialize(name)
    @name = name
  end
end
