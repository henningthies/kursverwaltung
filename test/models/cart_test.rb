require "test_helper"

class CartTest < ActiveSupport::TestCase
  test "loads the courses for the stored ids" do
    cart = Cart.new([ courses(:claude_code).id, courses(:prompt_engineering).id ])
    assert_equal 2, cart.size
    assert_includes cart.courses, courses(:claude_code)
  end

  test "deduplicates course ids" do
    id = courses(:claude_code).id
    cart = Cart.new([ id, id ])
    assert_equal 1, cart.size
  end

  test "total_cents sums the course prices" do
    cart = Cart.new([ courses(:claude_code).id, courses(:prompt_engineering).id ])
    assert_equal 12900 + 4900, cart.total_cents
  end

  test "add and remove change membership" do
    cart = Cart.new([])
    cart.add(courses(:claude_code).id)
    assert cart.include?(courses(:claude_code).id)
    cart.remove(courses(:claude_code).id)
    assert_not cart.include?(courses(:claude_code).id)
  end

  test "empty? reflects the courses" do
    assert Cart.new([]).empty?
    assert_not Cart.new([ courses(:claude_code).id ]).empty?
  end

  test "ignores nil and blank ids" do
    cart = Cart.new(nil)
    assert cart.empty?
  end

  test "excludes non-published courses (draft/done) from the cart" do
    # rails_performance ist draft, git_for_teams ist done — beide dürfen nicht kaufbar sein.
    cart = Cart.new([ courses(:claude_code).id, courses(:rails_performance).id, courses(:git_for_teams).id ])
    assert_equal [ courses(:claude_code) ], cart.courses
    assert_equal 1, cart.size
    assert_equal courses(:claude_code).price_cents, cart.total_cents
  end
end
