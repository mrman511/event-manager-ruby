require "test_helper"

class HostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @carian_user = User.create!({ email: "renna@carianroyalfamily.ai", password: "V@l1Dp45$" })
    @valid_post_host_params = {
      name: "Carian Royal Family",
      user_id: @carian_user.id
    }
    @valid_patch_host_params = {
      name: "Willful traitors all"
    }

    @valid_event_params= {
      title: "Fight the Golden Order round 1",
      starts: DateTime.now + 1.days,
      ends: DateTime.now + 2.days
    }
    @valid_event_params_2 = {
      title: "Kill my two fingers",
      starts: DateTime.now + 500.years,
      ends: DateTime.now + 500.years + 12.hours
    }

    @golden_user = User.create!({ email: "godwyn@goldenliniage.io", password: "V@l1Dp45$" })
    @base_host_params = {
      name: "Golden Lineage",
      users: [ @golden_user ]
    }
    @base_host = Host.create(@base_host_params)
    @base_host_event_params = {
      title: "Defeat the dragons",
      starts: DateTime.now + 2.days,
      ends: DateTime.now + 500.years - 2.days
    }
    @non_permitted_params = { ideology: "Our fates are in the stars" }
    # @base_host.create_event(@base_host_event_params)
  end

  # ###############
  # #### INDEX ####
  # ###############

  test "#index fetch should return response successful" do
    get hosts_url
    assert_response :success
  end

  test "#index should return an array of hosts as a response" do
    get hosts_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    body.each do |host|
      assert Host.find(id = host["id"])
    end
  end

  test "#index should return an Array when single Host exists" do
    Hosting.destroy_all
    Event.destroy_all
    Host.destroy_all
    Host.create!(@base_host_params)
    get hosts_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert_equal 1, body.length
  end

  test "#index should return an empty Array when no Hosts exists" do
    Hosting.destroy_all
    Event.destroy_all
    Host.destroy_all
    get hosts_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    assert body.empty?
  end

  test "#index should return hosts that have key events that contain a list of Events" do
    get hosts_url
    body = JSON.parse(response.body)
    assert_kind_of(Array, body)
    body.each do |host|
      host["events"].each do |event|
        fetched_host = Event.find(event["id"])
        assert_equal event["title"], fetched_host.title
      end
    end
  end

  # ################
  # ##### Show #####
  # ################

  test "#show should return response :success with valid host id" do
    get host_url(@base_host.id)
    assert_response :success
  end

  test "#show should return requested host" do
    get host_url(@base_host.id)
    body = JSON.parse(response.body)
    assert_equal body["name"], @base_host.name
  end

  test "#show should return response :not_found with invalid host id" do
    get host_url(0)
    assert_response :not_found
  end

  test "#show should raise error with no host id" do
    assert_raises {
      get host_url
    }
  end

  # ################
  # #### CREATE ####
  # ################

  test "#create should return response :accepted with valid params" do
    post hosts_url, params: @valid_post_host_params
    assert_response :accepted
  end

  test "#create return status :bad_request without name" do
    @valid_post_host_params.delete(:name)
    post hosts_url, params: @valid_post_host_params
    assert_response :bad_request
  end

  test "#create should add a Host with valid params" do
    assert_difference("Host.count") do
      post hosts_url, params: @valid_post_host_params
    end
  end

  test "#create should create a host with an array of one user at ['users']" do
    post hosts_url, params: @valid_post_host_params
    created_host = JSON.parse(response.body)
    assert_equal 1, created_host["users"].count
  end

  test "#create should create a host with single user id matching given params user_id" do
    post hosts_url, params: @valid_post_host_params
    created_host = JSON.parse(response.body)
    assert_equal @valid_post_host_params[:user_id], created_host["users"].first["id"]
  end

  test "#create should responed with Host that can be fetched from the database" do
    Hosting.destroy_all
    Event.destroy_all
    Host.destroy_all
    post hosts_url, params: @valid_post_host_params
    created_host = JSON.parse(response.body)
    fetched_host = Host.find(created_host["id"])
    assert_equal created_host["name"], fetched_host.name
  end

  test "#create returns status :bad_request when given only invalid params" do
    post hosts_url, params: @invalid_post_host_params
    assert_response :bad_request
  end

  test "#create returns response :accepted when valid_post_host_params includes non_permitted_params" do
    valid_plus_non_permitted_params=@valid_post_host_params.merge(@non_permitted_params)
    post hosts_url, params: valid_plus_non_permitted_params
    assert_response :accepted
  end

  test "#create response body does not include the non_permitted_params passed in the request" do
    valid_plus_non_permitted_params= @valid_post_host_params.merge(@non_permitted_params)
    post hosts_url, params: valid_plus_non_permitted_params
    body = JSON.parse(response.body)
    @non_permitted_params.each do |key, value|
      assert_nil body[key.to_s]
    end
  end

  # ##############
  # ### UPDATE ###
  # ##############

  test "#update should have response of :ok when given valid params" do
    patch host_url(@base_host), params: @valid_patch_host_params
    assert_response :accepted
  end

  test "#update should not change the user when user_id is given" do
    patch host_url(@base_host), params: { user_id: @carian_user.id }
    patched_host = JSON.parse(response.body)
    assert_not_equal patched_host["users"].first["id"], @carian_user[:id]
  end

  test "#update does not add a user to users when user_id is given" do
    patch host_url(@base_host), params: { user_id: @carian_user.id }
    patched_host = JSON.parse(response.body)
    assert_equal 1, patched_host["users"].count
  end

  test "#update should update the host when title is changed in the database" do
    assert_not_equal @base_host.name, @valid_patch_host_params[:name]
    patch host_url(@base_host), params: @valid_patch_host_params
    fetched_host = Host.find(@base_host.id)
    assert_equal @valid_patch_host_params[:name], fetched_host.name
  end

  test "#update should have response of :not_modified when given valid params equal to current host" do
    new_old_params = { name: @base_host.name }
    patch host_url(@base_host), params: new_old_params
    assert_response :not_modified
  end

  test "#update should return response :accepted non permitted params present" do
    params_with_non_permitted = @valid_patch_host_params.merge(@non_permitted_params)
    patch host_url(@base_host), params: params_with_non_permitted
    assert_response :accepted
  end

  test "#update does not add non permitted params to updated host" do
    params_with_non_permitted = @valid_patch_host_params.merge(@non_permitted_params)
    patch host_url(@base_host), params: params_with_non_permitted
    fetched_host = Host.find(@base_host.id)
    @non_permitted_params.each do |key|
      assert_nil fetched_host[key]
    end
  end

  test "#update should return response :not_found with invalid host" do
    patch host_url({ "id": 0 }), params: @valid_patch_host_params
    assert_response :not_found
  end

  test "#update should return response of :not_modified with no params" do
    patch host_url(@base_host), params: {}
    assert_response :not_modified
  end

  test "#update should raise error with no host id" do
    assert_raises(ActionController::UrlGenerationError) { patch host_url }
  end

  # ###############
  # ### DESTROY ###
  # ###############

  test "#destroy should return response of :ok when valid host is given" do
    delete host_url(@base_host)
    assert_response :ok
  end

  test "#destroy deletes the requested host form the database" do
    id = @base_host.id
    delete host_url(@base_host)
    assert_raises(ActiveRecord::RecordNotFound) { Host.find(id) }
  end

  test "#destroy should return response :not_found when invalid host is given" do
    delete host_url({ "id": 0 })
    assert_response :not_found
  end

  test "#destroy should raise error with no event id" do
    assert_raises(ActionController::UrlGenerationError) { delete host_url }
  end
end
