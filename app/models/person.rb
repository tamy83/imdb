class Person < ActiveRecord::Base

  has_many :crew_members
  has_many :works, through: :crew_members
  has_and_belongs_to_many :crew_members_roles, through: :crew_members

  validates :name, presence: true
  validates :photo_url, format: URI::regexp(%w(http https)), allow_nil: true
  validates :profile_url, format: URI::regexp(%w(http https)), allow_nil: true
#  validates :work_ranking_valid?, if: :work_ranking 

end
