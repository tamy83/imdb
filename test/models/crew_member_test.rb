require 'test_helper'

class CrewMemberTest < ActiveSupport::TestCase
  test "create crew member" do
    crew_member = CrewMember.new(person: Person.find_by(id: 1), work: Work.find_by(id:2)) 
    assert crew_member.valid?
  end
end
