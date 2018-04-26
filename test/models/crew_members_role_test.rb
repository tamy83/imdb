require 'test_helper'

class CrewMembersRoleTest < ActiveSupport::TestCase
  test "create crew members role" do
    crew_members_role = CrewMembersRole.new(crew_member: CrewMember.find_by(id: 1), role: Role.find_by(id:1)) 
    crew_members_role.save
    assert_nil crew_members_role[:errors]
  end

  test "cascade destroy person" do
    crew_member = CrewMember.find_by(id: 1)
    crew_members_role = CrewMembersRole.new(crew_member: crew_member, role: Role.find_by(id:1))
    assert_not_nil crew_member
    assert_not_nil crew_members_role
    crew_members_role.save
    person = crew_member.person
    person.destroy
    assert_nil person[:errors]
    cm = CrewMember.find_by(id: 1)
    assert_nil cm
    cmr = CrewMembersRole.find_by(crew_member_id: 1, role_id: 1)
    assert_nil cmr
  end
end
