require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @learner = users(:learner)
    @course  = courses(:prompt_engineering)
  end

  test "cart requires login" do
    get cart_url
    assert_redirected_to new_session_url
  end

  test "adding a course puts it in the session cart" do
    sign_in_as(@learner)
    post add_item_cart_url(course_id: @course.id)
    assert_redirected_to cart_url
    follow_redirect!
    assert_select "p", text: @course.title
  end

  test "adding the same course twice keeps it once" do
    sign_in_as(@learner)
    post add_item_cart_url(course_id: @course.id)
    post add_item_cart_url(course_id: @course.id)
    get cart_url
    assert_select "div.divide-y > div", count: 1
  end

  test "removing a course takes it out of the cart" do
    sign_in_as(@learner)
    post add_item_cart_url(course_id: @course.id)
    delete remove_item_cart_url(course_id: @course.id)
    assert_redirected_to cart_url
    follow_redirect!
    assert_select "p", text: /Warenkorb ist leer/
  end

  test "cart shows the total" do
    sign_in_as(@learner)
    post add_item_cart_url(course_id: courses(:claude_code).id)
    get cart_url
    assert_match(/129,00/, response.body)
  end
end
