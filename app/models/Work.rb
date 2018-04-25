class Work < ActiveRecord::Base
  has_many :crew_members, through: crew_member

  enum type: [ :movie, :tv_show ]
  
  validates :title, presence: true
  validates :rating, numericality: { only_float: true }
  validates :url, format: URI::regexp(%w(http https))
  
  def initialize(title, url, rating, type)
    @title = title
    @url = url
    @rating = rating
    @type = type
  end

end
