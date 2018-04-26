class Work < ActiveRecord::Base

  has_many :crew_members, dependent: :destroy
  has_many :people, through: :crew_members
  has_many :roles, through: :crew_members

  enum category: [ :movie, :tv_show ]
  
  validates :title, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :url, format: URI::regexp(%w(http https)), allow_nil: true
  
end
