require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @base_event = Event.create({
      title: "Fill the Lordvessel",
      tagline: "Gather the lord souls",
      description: "Gather the souls of the Seath, Nito, The Witch of Izalith, and Nito.",
      postscript: "The fire fades",
      starts: DateTime.now() + 1.minutes,
      ends: DateTime.now() + 50.hours,
      location: "Kiln of the First Flame"
    })
    @invalid_event_params = {
      title: "Usurp",
      starts: DateTime.now() - 1.years
    }
    @valid_event_params = {
      title: "Link the Fire",
      tagline: "We must prolong the age of fire.",
      description: "The strongest warrior must link the fire.",
      postscript: "Fear the age of dark.",
      starts: DateTime.now() + 1.minutes,
      ends: DateTime.now() + 1000.years,
      location: "Kiln of the First Flame"
    }
<<<<<<< HEAD
    @non_permitted_params = {
      first_name: "Gwyn"
    }
=======
>>>>>>> 8c9a0cc (Created Event controller including routes for Index, show, and Create)
  end

  test "#Index returns response :ok" do
    get events_url
    assert_response :ok
  end

  test "#index should return an Array" do
    get events_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
  end

  test "#index should return an array where all items can be retrieved from Event Model" do
    get events_url
    body = JSON.parse(response.body)
    body.each do |event|
      fetched_event = Event.find(event["id"])
      assert_equal event["title"], fetched_event["title"]
    end
  end

  test "#index should return an Array when single Event exists" do
    Event.destroy_all
    Event.create!(@valid_event_params)
    get events_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty Array when no events exists" do
    Event.destroy_all
    get events_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert body.empty?
  end

  test "#show should respond with :ok when fetched with valid Event id" do
    get event_url(@base_event)
    assert_response :ok
  end

  test "#show fetched Event should match created Event" do
    get event_url(@base_event)
    fetched_event = JSON.parse(response.body)
    assert_equal @base_event.id, fetched_event["id"]
  end

  test "#create should return response :accepted with valid params" do
    post events_url, params: @valid_event_params
    assert_response :accepted
  end

  test "#create should create Event with valid params" do
    assert_difference("Event.count") do
      post events_url, params: @valid_event_params
    end
  end

  test "#create should responed with Event that can be fetched from the database" do
    post events_url, params: @valid_event_params
    created_event = JSON.parse(response.body)
    fetched_event = Event.find(created_event["id"])
    assert_equal created_event["title"], fetched_event["title"]
    assert_equal created_event["tagline"], fetched_event["tagline"]
    assert_equal created_event["description"], fetched_event["description"]
    assert_equal created_event["postscript"], fetched_event["postscript"]
    assert_equal created_event["location"], fetched_event["location"]
  end

  test "#create returns status :unprocessable_entity when given invalid params" do
    post events_url, params: @invalid_event_params
    assert_response :unprocessable_entity
  end

  test "#create returns key 'title' with array that includes 'can't be blank' with missing title" do
    @valid_event_params.delete(:title)
    post events_url, params: @valid_event_params
    body = JSON.parse(response.body)
    assert(body["title"].include? "can't be blank")
  end

  test "#create returns key 'starts' with array that includes 'can't be blank' with missing status" do
    @valid_event_params.delete(:starts)
    post events_url, params: @valid_event_params
    body = JSON.parse(response.body)
    assert(body["starts"].include? "can't be blank")
  end

  test "#create returns response :accepted when valid_event_params includes non_permitted_params" do
    valid_plus_non_permitted_params= @valid_event_params.merge(@non_permitted_params)
    post events_url, params: valid_plus_non_permitted_params
    assert_response :accepted
  end

  test "#create response body does not include the non_permitted_params passed in the request" do
    valid_plus_non_permitted_params= @valid_event_params.merge(@non_permitted_params)
    post events_url, params: valid_plus_non_permitted_params
    body = JSON.parse(response.body)
    @non_permitted_params.each do |key, value|
      assert_nil body[key.to_s]
    end
  end
end
