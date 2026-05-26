require "test_helper"

class UserSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin   = users(:admin)
    @learner = users(:learner)
  end

  test "new login form is reachable without login" do
    get new_session_url
    assert_response :success
    assert_select "h1", text: /Willkommen zurück/
  end

  test "login with correct credentials redirects and authenticates" do
    post session_url, params: { email: @learner.email, password: "geheim123" }
    assert_redirected_to root_url
  end

  test "login with wrong password is rejected" do
    post session_url, params: { email: @learner.email, password: "falsch" }
    assert_response :unprocessable_entity
    assert_select "p", text: /falsch/
  end

  test "logout clears the session" do
    sign_in_as(@admin)
    delete session_url
    assert_redirected_to root_url
    # danach ist ein admin-geschützter Bereich nicht mehr erreichbar
    get courses_url
    assert_redirected_to new_session_url
  end

  test "admin can reach admin-only courses index" do
    sign_in_as(@admin)
    get courses_url
    assert_response :success
  end

  test "learner is blocked from admin-only courses index" do
    sign_in_as(@learner)
    get courses_url
    assert_redirected_to root_url
  end

  test "anonymous visitor is redirected to login on admin pages" do
    get courses_url
    assert_redirected_to new_session_url
  end
end
