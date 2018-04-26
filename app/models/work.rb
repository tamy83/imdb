class Work < ActiveRecord::Base
  has_many :crew_members, through: crew_member

  enum type: [ :movie, :tv_show ]
  
  attr_accessor :title, :url, :rating
  
  validates :title, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :url, format: URI::regexp(%w(http https))
  
end
