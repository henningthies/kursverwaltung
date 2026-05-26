module AuthTestHelper
  # Loggt einen User über den echten Login-Flow ein (setzt das signierte Session-Cookie).
  def sign_in_as(user, password: "geheim123")
    post session_url, params: { email: user.email, password: password }
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include AuthTestHelper
end
