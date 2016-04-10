module AuthenticationStub
  def signed_in_user
    @user ||= User.find_or_create_from_auth_hash!(
                mock_auth_hash
              )
  end

  def stub_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(mock_auth_hash)
  end

  def sign_in_user
    visit new_session_path
    click_on "Sign in with Google"
  end

  def mock_auth_hash
    {
      provider: 'google',
      uid: '12345',
      info: {
        name: "Stub User",
        email: "stub.user@example.org"
      }
    }
  end
end

RSpec.configure do |config|
  config.include AuthenticationStub

  config.before(:each) do
    stub_omniauth
  end
end
