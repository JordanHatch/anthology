module UserSessionStubHelper
  def stub_user_session
    @controller.session[:user_id] = stub_user.id
  end

  def stub_user
    @user ||= create(:user)
  end
end
