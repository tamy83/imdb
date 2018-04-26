require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test "valid role" do
    role = Role.new(name: "director")
    assert role.valid?
  end

  test "invalid without name" do
    role = Role.new
    refute role.valid?, 'role missing name'
    assert_not_nil role.errors[:name]
  end
end
