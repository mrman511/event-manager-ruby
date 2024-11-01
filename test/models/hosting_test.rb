require "test_helper"

class HostingTest < ActiveSupport::TestCase
  setup do
    @jiren = User.create!({ email: "witch_hunter_jiren@yahoo.ca", password: "V@l1dPas5" })
    @valid_host_params = { name: "Redmanes", users: [ @jiren ] }
  end

  test "hosting is created when user is added to host" do
    assert_difference("Hosting.count") do
      Host.create!(@valid_host_params)
    end
  end

  test "hosting that is created when user is added to host has a valid user_id" do
    created_host = Host.create!(@valid_host_params)
    fetched_hosting = Hosting.last
    assert_equal fetched_hosting.user_id, @jiren.id
    assert_equal fetched_hosting.host_id, created_host.id
  end
end
