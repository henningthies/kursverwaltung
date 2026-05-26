require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new is reachable without login" do
    get new_registration_url
    assert_response :success
    assert_select "h1", text: /Konto erstellen/
  end

  test "registering creates a learner and logs in" do
    assert_difference "User.count", 1 do
      post registration_url, params: { user: {
        name: "Neue Nutzerin", email: "neu@example.com",
        password: "geheim123", password_confirmation: "geheim123"
      } }
    end
    user = User.find_by(email: "neu@example.com")
    assert_equal "learner", user.role
    assert_redirected_to root_url
    # eingeloggt: kein Redirect mehr auf die Login-Seite (Epic 2 macht Root zum Katalog)
    delete session_url
    assert_redirected_to root_url
  end

  test "registration with mismatched password is rejected" do
    assert_no_difference "User.count" do
      post registration_url, params: { user: {
        name: "X", email: "x@example.com",
        password: "geheim123", password_confirmation: "anders"
      } }
    end
    assert_response :unprocessable_entity
  end

  test "registration with a taken email is rejected" do
    assert_no_difference "User.count" do
      post registration_url, params: { user: {
        name: "X", email: users(:learner).email,
        password: "geheim123", password_confirmation: "geheim123"
      } }
    end
    assert_response :unprocessable_entity
  end
end
