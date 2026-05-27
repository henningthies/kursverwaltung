require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:learner)
  end

  test "requires a name" do
    @user.name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:name], "muss ausgefüllt werden"
  end

  test "requires an email" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email must be unique" do
    duplicate = User.new(name: "X", email: @user.email, password: "geheim123", role: "learner")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "ist bereits vergeben"
  end

  test "email is normalized to lowercase and trimmed" do
    user = User.create!(name: "Max", email: "  MAX@Example.COM ", password: "geheim123")
    assert_equal "max@example.com", user.email
  end

  test "rejects a role outside ROLES" do
    @user.role = "superuser"
    assert_not @user.valid?
    assert_includes @user.errors[:role], "ist kein gültiger Wert"
  end

  test "accepts every role in ROLES" do
    User::ROLES.each do |role|
      @user.role = role
      assert @user.valid?, "#{role} sollte gültig sein"
    end
  end

  test "authenticates with the correct password" do
    assert @user.authenticate("geheim123")
    assert_not @user.authenticate("falsch")
  end

  test "admin? and learner? reflect the role" do
    assert users(:admin).admin?
    assert_not users(:admin).learner?
    assert users(:learner).learner?
    assert_not users(:learner).admin?
  end

  test "participant belongs_to user is optional" do
    participant = Participant.create!(name: "Ohne Konto", email: "ohne@example.com")
    assert_nil participant.user
    assert participant.valid?
  end

  test "participant can be linked to a user" do
    participant = Participant.create!(name: "Mit Konto", email: "mit@example.com", user: @user)
    assert_equal @user, participant.user
  end
end
