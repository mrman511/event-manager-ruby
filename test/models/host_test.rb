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
      ends: DateTime.now() + 4.hours,
    }

    @valid_event_params = {
      title: "Coming of a Dynasty",
      tagline: "Become our bloody finger",
      location: "Mohgwyn Palace",
      description: "You must abide alone a while. Welcome, honoured guest. To the birthplace of our dynasty! Miquella is mine and mine alone.",
      postscript: "Praise the formless mother",
      starts: DateTime.now() + 1.hours,
      ends: DateTime.now() + 4.hours,
    }

    @valid_host_params = {
      name: "Mohgwyn Dynasty"
    }

    @base_event = Event.create({
      title: "Kill the Graven Witch",
      tagline: "We must defeat Sellen",
      location: "Raya Lucaria Library",
      description: "Sellen, Graven Witch, enemy of Caria. I vow this time to crush both your frame and your primal glintstone. I am Jerren, bringer of your death. Do not forget.",
      starts: DateTime.now() + 1.hours,
      ends: DateTime.now() + 4.hours,
    })
    @base_host = Host.create({ name: "Redmanes" })
    @base_host.add_event(@base_event)
  end
  
  test "#create creates a host with valid params without an event" do
    assert_difference("Host.count"){
      Host.create!(@valid_host_params)
    }
  end

  test "#create creates a host that can be searched for in the database with valid params" do
    created_host = Host.create(@valid_host_params)
    fetched_host = Host.find(created_host.id)
    assert_equal created_host.name, fetched_host.name
  end
  
  test "#add_event adds an event to a hosts events when a host with no events adds an event" do
    created_host = Host.create(@valid_host_params)
    new_event = Event.create(@valid_event_params)
    assert_equal created_host.events.length, 0
    created_host.add_event(new_event)
    assert_equal created_host.events[0].id, new_event.id
  end

  test "#add_event adds an event to a hosts events when a host already has one or more events" do
    assert @base_host.events.length > 0
    new_event = Event.create(@base_host_event_params)
    @base_host.add_event(new_event)
    assert true if @base_host.events.any? { |event| event.id == new_event.id}
  end
end
