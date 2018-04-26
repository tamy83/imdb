class Person < ActiveRecord::Base

  has_many :crew_members, dependent: :destroy
  has_many :works, through: :crew_members
  has_many :roles, through: :crew_members

  validates :name, presence: true
  validates :photo_url, format: URI::regexp(%w(http https)), allow_nil: true
  validates :profile_url, format: URI::regexp(%w(http https)), allow_nil: true
#  validates :work_ranking_valid?, if: :work_ranking 

end
