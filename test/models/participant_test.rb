require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  setup do
    @participant = participants(:alice)
  end

  test "requires a name" do
    @participant.name = ""
    assert_not @participant.valid?
    assert_includes @participant.errors[:name], "muss ausgefüllt werden"
  end

  test "requires an email" do
    @participant.email = ""
    assert_not @participant.valid?
    assert_includes @participant.errors[:email], "muss ausgefüllt werden"
  end

  test "rejects a duplicate email" do
    duplicate = Participant.new(name: "Kopie", email: @participant.email)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "ist bereits vergeben"
  end
end
