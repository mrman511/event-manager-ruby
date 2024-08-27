require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      email: "valid@email.email",
      password: ENV["VALID_PASSWORD_TEST"]
    }
    @invalid_email = "invalid_email"
  end

  test "#create! creates a user that can be fetched from the database" do
    created_user = User.create!(@valid_attributes)
    fetched_user = User.find(created_user.id)
    assert_equal @valid_attributes[:email], fetched_user.email
  end

  test "#email is required to create a user" do
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes.except(:email)) }
  end

  test "#email can not be user to create more than one user" do
    first_user = User.create!(@valid_attributes)
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#email needs to be proper format" do
    @valid_attributes[:email] = @invalid_email
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#email needs to be converted to lowercase" do
    @valid_attributes[:email] = @valid_attributes[:email].upcase
    created_user = User.create!(@valid_attributes)
    assert_equal @valid_attributes[:email].downcase, created_user.email
  end

  test "#password is required to create a user" do
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes.except(:password)) }
  end

  test "#password cannot be less than 8 characters" do
    @valid_attributes[:password] = ENV["FOUR_CHARACTER_PASSWORD_TEST"]
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password cannot be longer than 40 characters" do
    @valid_attributes[:password] = ENV["FOUR_CHARACTER_PASSWORD_TEST"] + "a" * 37
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password must have one lowercase letter" do
    @valid_attributes[:password] = @valid_attributes[:password].upcase
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password must have one uppercase letter" do
    @valid_attributes[:password] = @valid_attributes[:password].downcase
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password must have one number" do
    @valid_attributes[:password] = ENV["NO_NUM_PASSWORD_TEST"]
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password must have one symbol" do
    @valid_attributes[:password] = ENV["NO_SYMBOL_PASSWORD_TEST"]
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end
end
