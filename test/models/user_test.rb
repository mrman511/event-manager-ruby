require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      email: "ashen_one@firelink.net",
      password: "V@l1dPa$5"
    }
    @ringfinger = User.create({
      email: "leonhard@rosariasfingers.com",
      password: "R1nGf|ng3r"
    })
    @rosariasfingers = Host.create({ name: "Rosaria's Fingers", users: [] })
    @join_rosarias_fingers = @rosariasfingers.create_event({
      title: "Join Rosaria's Fingers",
      starts: DateTime.now + 3.hours,
      ends: DateTime.now + 4.hours
    })
    @invalid_email = "leonard_rosarias"
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
    @valid_attributes[:password] = "Inv@l1d"
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password cannot be longer than 72 characters" do
    @valid_attributes[:password] = "F@1l" + ("a" * 69)
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
    @valid_attributes[:password] = "nONumbeR$"
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#password must have one symbol" do
    @valid_attributes[:password] = "n0Symb0ls"
    assert_raises("ActiveRecord::RecordInvalid") { User.create!(@valid_attributes) }
  end

  test "#sent_invitaions of user used in sent_by of a created Invitation includes Invitaion created" do
    invitation = Invitation.create({
      sent_by: @ringfinger,
      event: @join_rosarias_fingers,
      max_guests: 0
    })
    assert_includes @ringfinger.sent_invitations, invitation
  end

  test "#sent_invitations length increases by one if user used in sent_by of a created Invitation" do
    assert_difference("@ringfinger.sent_invitations.count") do
      Invitation.create({
        sent_by: @ringfinger,
        event: @join_rosarias_fingers,
        max_guests: 0
      })
    end
  end
end
