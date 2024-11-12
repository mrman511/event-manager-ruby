require "test_helper"

class HostTest < ActiveSupport::TestCase
  setup do
    @base_host_event_params = {
      title: "The Radahn Festival",
      tagline: "Face Gerneral Redahn",
      location: "Redmane Castle",
      description: "Champions, welcome! The stars have aligned! The festival is nigh! General Radahn, mightiest demigod of the Shattering, awaits you! A celebration of war! The Radahn Festival!",
      postscript: "Are you good and prepared, young chum? The festival begins!",
      starts: DateTime.now() + 1.hours,
      ends: DateTime.now() + 4.hours
    }

    @valid_event_params = {
      title: "Coming of a Dynasty",
      tagline: "Become our bloody finger",
      location: "Mohgwyn Palace",
      description: "You must abide alone a while. Welcome, honoured guest. To the birthplace of our dynasty! Miquella is mine and mine alone.",
      postscript: "Praise the formless mother",
      starts: DateTime.now() + 1.hours,
      ends: DateTime.now() + 4.hours
    }

    @dynasty_user = User.create!(email: "mohg@moghwyndynasty.org", password: "V@l1dPa$5")

    @valid_host_params = {
      name: "Mohgwyn Dynasty",
      users: [ @dynasty_user ]
    }

    @redmanes_leader = User.create!({ email: "starscurge@hotmail.com", password: "V@l1dPa$5"  })
    @redmanes_user = User.create!({ email: "witch_hunter_jiren@yahoo.ca", password: "V@l1dPa$5" })
    @redmanes_user_2 = User.create!({ email: "freyja@yahoo.ca", password: "V@l1dPa$5" })
    @base_host = Host.create({ name: "Redmanes", users: [ @redmanes_leader, @redmanes_user ] })
    @base_event = Event.create({
      host: @base_host,
      title: "Kill the Graven Witch",
      tagline: "We must defeat Sellen",
      location: "Raya Lucaria Library",
      description: "Sellen, Graven Witch, enemy of Caria. I vow this time to crush both your frame and your primal glintstone. I am Jerren, bringer of your death. Do not forget.",
      starts: DateTime.now() + 36.hours,
      ends: DateTime.now() + 40.hours
    })
  end

  # ##################
  # ##### CREATE #####
  # ##################

  test "#create creates a host with valid params without an event" do
    assert_difference("Host.count") {
      Host.create!(@valid_host_params)
    }
  end

  test "#create raises ActiveRecord::RecordInvalid when no users provided" do
    @valid_host_params.delete(:users)
    assert_raises(ActiveRecord::RecordInvalid) do
      host = Host.create!(@valid_host_params)
    end
  end

  test "#create does not create a new User when user is added to new host" do
    assert_difference("User.count", 0) do
      Host.create!(@valid_host_params)
    end
  end

  test "#create raises ActiveRecord::RecordInvalid empty users provided" do
    @valid_host_params[:users] = []
    assert_raises(ActiveRecord::RecordInvalid) do
      Host.create!(@valid_host_params)
    end
  end

  test "#create raises ActiveRecord::AssociationTypeMismatch invalid users provided" do
    @valid_host_params[:users] = [ 0 ]
    assert_raises(ActiveRecord::AssociationTypeMismatch) do
      Host.create!(@valid_host_params)
    end
  end

  test "#create raises ActiveRecord::AssociationTypeMismatch different model instance provided as users" do
    @valid_host_params[:users] = [ Host.first ]
    assert_raises(ActiveRecord::AssociationTypeMismatch) do
      Host.create!(@valid_host_params)
    end
  end

  test "#create adds a user to users that is retrieveable from the database" do
    created_host = Host.create!(@valid_host_params)
    assert User.find(created_host.users.first.id)
  end

  test "#create raises ActiveRecord::RecordInvalid without name provided" do
    @valid_host_params.delete(:name)
    assert_raises(ActiveRecord::RecordInvalid) do
      Host.create!(@valid_host_params)
    end
  end

  test "#create creates a host that can be searched for in the database with valid params" do
    created_host = Host.create(@valid_host_params)
    fetched_host = Host.find(created_host.id)
    assert_equal created_host.name, fetched_host.name
  end

  #   # ##################
  #   # ## CREATE_EVENT ##
  #   # ##################

  test "#create_event creates a new event with valid_params" do
    assert_difference("Event.count") do
      @base_host.create_event(@base_host_event_params)
    end
  end

  test "#create_event adds an event to a hosts events when a host with no events adds an event" do
    created_host = Host.create(@valid_host_params)
    assert_difference("created_host.events.length") do
      event = created_host.create_event(@valid_event_params)
    end
  end

  test "create_event returns event errors raised by Event model" do
    @valid_event_params.delete(:title)
    created_host = Host.create(@valid_host_params)
    event = created_host.create_event(@valid_event_params)
    assert event.errors[:title].include?("can't be blank")
    assert event.errors[:title].include?("is too short (minimum is 8 characters)")
  end

  test "#create_event returns an event with valid params with the host called on as the host" do
    created_host = Host.create(@valid_host_params)
    created_event = created_host.create_event(@valid_event_params)
    assert_equal @valid_event_params[:title], created_event.title
    # assert_equal @valid_event_params[:starts].strftime("%m/%d/%Y %I:%M"), created_event.starts.strftime("%m/%d/%Y %I:%M")
    # assert_equal @valid_event_params[:ends].strftime("%m/%d/%Y %I:%M"), created_event.ends.strftime("%m/%d/%Y %I:%M")
    assert_equal created_host, created_event.host
    assert created_event.instance_of?(Event)
  end

  test "#add_event adds an event to a hosts events when a host already has one or more events" do
    assert @base_host.events.length > 0
    new_event = @base_host.create_event(@base_host_event_params)
    assert true if @base_host.events.any? { |event| event.id == new_event.id }
  end

  test "#add_event raises Exception if host has adds event that starts during another hosted event" do
    @base_host.create_event(@base_host_event_params)
    @base_host_event_params[:starts] += 4.minutes
    @base_host_event_params[:ends] += 4.minutes
    assert_raises(Exception) { @base_host.create_event(@base_host_event_params) }
  end

  test "#add_event raises Exception if host is already hosting an event that occurs during the new event" do
    @base_host.create_event(@base_host_event_params)
    @base_host_event_params[:starts] -= 4.minutes
    @base_host_event_params[:ends] += 4.minutes
    assert_raises(Exception) { @base_host.create_event(@base_host_event_params) }
  end

  test "#add_event raises Exception with no params provided" do
    assert_raises(Exception) { @base_host.create_event() }
  end

  # ################
  # # DELETE_EVENT #
  # ################

  test "#delete_event deletes an event with valid hosted event id" do
    created_event = @base_host.create_event(@base_host_event_params)
    assert_difference("Event.count", -1) do
      @base_host.delete_event(created_event.id)
    end
  end

  test "#delete_event removes event from host events with valid hosted event id" do
    created_event = @base_host.create_event(@base_host_event_params)
    assert_difference("@base_host.events.count", -1) do
      @base_host.delete_event(created_event.id)
    end
  end

  test "#delete_event raises Exception with no params provided" do
    assert_raises(Exception) { @base_host.delete_event() }
  end

  test "#delete_event raises Exception with invalid params provided" do
    assert_raises(Exception) { @base_host.delete_event(5) }
  end

  # ################
  # ### Add User ###
  # ################

  test "#add_user adds a user to host users with valid user" do
    initial_count = @base_host.users.count
    @base_host.add_user(@redmanes_user_2)
    assert_equal @base_host.users.count, initial_count + 1
  end

  test "#add_user raises expception when no user provided" do
    assert_raises(Exception) do
      @base_host.add_user()
    end
  end

  test "#add_user raises expception when non user instance provided" do
    new_host = Host.create(@valid_host_params)
    assert_raises(Exception) do
      @base_host.add_user(new_host)
    end
  end

  test "#add_user raises expception when trying to add user that already exists in users" do
    assert_raises(Exception) do
      @base_host.add_user(@base_host.users.first)
    end
  end

  # ###################
  # ### Remove User ###
  # ###################

  test "#remove_user removes a user from a hosts users" do
    initial_count = @base_host.users.count
    @base_host.remove_user(@redmanes_user)
    assert_equal @base_host.users.count, initial_count - 1
  end

  test "#remove_user raises Exception when called with a nonuser argument" do
    assert_raises (Exception) {
      @base_host.remove_user({ type: "Non User" })
    }
  end

  test "#remove_user raises Exception when called with a User not in users" do
    assert_raises (Exception) {
      @base_host.remove_user(@redmanes_user_2)
    }
  end

  test "#remove_user raises Exception when attempting to remove the final user" do
    @base_host.users.each do |user|
      if @base_host.users.count == 1
        assert_raises(Exception) {
          @base_host.remove_user(user)
        }
      else
        @base_host.remove_user(user)
      end
    end
  end
end
