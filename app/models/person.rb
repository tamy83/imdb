class Person < ActiveRecord::Base
#  has_many :work, through: crew_member

#  attr_accessor :name, :photo_url, :profile_url, :birthdate #, :work_ranking

  validates :name, presence: true
  validates :photo_url, format: URI::regexp(%w(http https)), allow_nil: true
  validates :profile_url, format: URI::regexp(%w(http https)), allow_nil: true
#  validates :work_ranking_valid?, if: :work_ranking 

end
