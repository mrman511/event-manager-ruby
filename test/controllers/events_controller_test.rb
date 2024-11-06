require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @base_user = User.create({ email: "chosen@undead.org", password: "V@l1dPa5$" })
    @base_host = Host.create({ name: "Chosen Undead", users: [ @base_user ] })
    @base_event = @base_host.create_event({
      title: "Fill the Lordvessel",
      tagline: "Gather the lord souls",
      description: "Gather the souls of the Seath, Nito, The Witch of Izalith, and Nito.",
      postscript: "The fire fades",
      starts: DateTime.now() + 50.hours,
      ends: DateTime.now() + 60.hours,
      location: "Kiln of the First Flame"
    })
    @invalid_event_params = {
      title: "Usurp",
      starts: DateTime.now() - 1.years,
      ends: DateTime.now() - 2.months
    }
    @valid_event_params = {
      title: "Link the Fire",
      tagline: "We must prolong the age of fire.",
      description: "The strongest warrior must link the fire.",
      postscript: "Fear the age of dark.",
      starts: DateTime.now() + 1000.years,
      ends: DateTime.now() + 1005.years,
      location: "Kiln of the First Flame"
    }
    @non_permitted_params = {
      first_name: "Gwyn"
    }
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

  # ##############
  # ### CREATE ###
  # ##############

  test "#create should return response :accepted with valid params" do
    post events_url, params: { event: @valid_event_params, host: @base_host.id }
    assert_response :accepted
  end

  test "#create should return response of :bad_request with no params" do
    post events_url, params: {}
    assert_response :bad_request
  end

  test "#create should create Event with valid params" do
    assert_difference("Event.count") do
      post events_url, params: { event: @valid_event_params, host: @base_host.id }
    end
  end

  test "#create should create Event with host that can be retrieved from the database" do
    post events_url, params: { event: @valid_event_params, host: @base_host.id }
    body = JSON.parse(response.body)
    assert Host.find(body["host_id"])
  end

  test "#create should create Event and add that event to host.events" do
    post events_url, params: { event: @valid_event_params, host: @base_host.id }
    body = JSON.parse(response.body)
    host = Host.find(@base_host.id)
    assert true if host.events.any? { |event| (event.id == body["id"]) }
  end

  test "#create should responed with Event that can be fetched from the database" do
    post events_url, params: { event: @valid_event_params, host: @base_host.id }
    created_event = JSON.parse(response.body)
    fetched_event = Event.find(created_event["id"])
    assert_equal created_event["title"], fetched_event.title
    assert_equal created_event["tagline"], fetched_event.tagline
    assert_equal created_event["description"], fetched_event.description
    assert_equal created_event["postscript"], fetched_event.postscript
    assert_equal created_event["location"], fetched_event.location
    assert_equal created_event["host_id"], fetched_event.host_id
  end

  test "#create returns status :unprocessable_entity when given invalid params" do
    post events_url, params: { event: @invalid_event_params, host: @base_host.id }
    assert_response :unprocessable_entity
  end

  test "#create returns status :bad_request when given invalid host" do
    post events_url, params: { event: @valid_event_params, host: 0 }
    assert_response :bad_request
  end

  test "#create returns error object from Event when Event is not valid" do
    @valid_event_params.delete(:title)
    post events_url, params: { event: @valid_event_params, host: @base_host.id }
    body = JSON.parse(response.body)
    assert(body["title"].include? "can't be blank")
    assert(body["title"].include? "is too short (minimum is 8 characters)")
  end

  test "#create returns response :accepted when valid_event_params includes non_permitted_params" do
    valid_plus_non_permitted_params= @valid_event_params.merge(@non_permitted_params)
    post events_url, params: { event: valid_plus_non_permitted_params, host: @base_host.id }
    assert_response :accepted
  end

  test "#create response body does not include the non_permitted_params passed in the request" do
    valid_plus_non_permitted_params= @valid_event_params.merge(@non_permitted_params)
    post events_url, params: { event: valid_plus_non_permitted_params, host: @base_host.id }
    body = JSON.parse(response.body)
    @non_permitted_params.each do |key, value|
      assert_nil body[key.to_s]
    end
  end

  # # ##############
  # # ### UPDATE ###
  # # ##############

  test "#update should have response of :ok when given valid params" do
    patch event_url(@base_event), params: { event: @valid_event_params }
    assert_response :accepted
  end

  test "#update should update the event in the database" do
    patch event_url(@base_event), params: { event: @valid_event_params }
    fetched_event = Event.find(@base_event.id)
    @valid_event_params.delete(:starts)
    @valid_event_params.delete(:ends)
    @valid_event_params.each do |key, value|
      assert_equal value, fetched_event[key.to_s]
    end
  end

  test "#update should return response :accepted non permitted params present" do
    params_with_non_permitted = @valid_event_params.merge(@non_permitted_params)
    patch event_url(@base_event), params: { event: params_with_non_permitted }
    assert_response :accepted
  end

  test "#update does not add non permitted params to updated event" do
    params_with_non_permitted = @valid_event_params.merge(@non_permitted_params)
    patch event_url(@base_event), params: { event: params_with_non_permitted }
    fetched_event = Event.find(@base_event.id)
    @non_permitted_params.each do |key|
      assert_nil fetched_event[key]
    end
  end

  test "#update should return response :not_found with invalid event" do
    patch event_url({ "id": 0 }), params: { event: @valid_event_params }
    assert_response :not_found
  end

  test "#update should return response of :unprocessable_entity with no params" do
    patch event_url(@base_event), params: {}
    assert_response :unprocessable_entity
  end

  test "#update should raise error with no event id" do
    assert_raises { patch event_url }
  end

  # ###############
  # ### DESTROY ###
  # ###############

  test "#destroy should return response of :ok when valid event is given" do
    delete event_url(@base_event)
    assert_response :ok
  end

  test "#destroy deletes the requested item form the database" do
    id = @base_event.id
    delete event_url(@base_event)
    assert_raises(ActiveRecord::RecordNotFound) { Event.find(id) }
  end

  test "#destroy removes the event from a hosts events" do
    event = @base_host.create_event(@valid_event_params)
    event_id = event.id
    delete event_url(event)
    fetched_host = Host.find(@base_host.id)
    fetched_host.events.each do |comparison_event|
      assert_not_equal event_id, comparison_event.id
    end
  end

  test "#destroy should return response :bad_request when invalid event is given" do
    delete event_url({ "id": 0 })
    assert_response :bad_request
  end

  test "#destroy should raise error with no event id" do
    assert_raises(ActionController::UrlGenerationError) { delete event_url }
  end
end
