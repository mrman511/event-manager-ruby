class CurrentTest < ActiveSupport::TestCase
  setup do
    @valid_user_params = {
      email: "valid@email.email",
      password: "V@lidP45$"
    }
  end
  test "#Current.user sets a current user that can be read" do
    user = User.create!(@valid_user_params)
    Current.user = user
    assert_equal Current.user, user
  end
end
