require "test_helper"

class EventTest < ActiveSupport::TestCase
  def setup
    @min_accepted_valid_params = {
      title: "Fill the Lordvessel",
      tagline: "Gather the lord souls",
      description: "Gather the souls of the Seath, Nito, The Witch of Izalith, and Nito.",
      postscript: "The fire fades",
      starts: DateTime.now() + 1.minutes,
      ends: DateTime.now() + 50.hours,
      location: "Kiln of the First Flame"
    }
  end

  test "#create! creates an event with minimum accepted valid params" do
    assert_difference("Event.count") do
      Event.create!(@min_accepted_valid_params)
    end
  end

  test "#create adds error 'can't be blank' to error.title with no title" do
    @min_accepted_valid_params.delete(:title)
    event = Event.create(@min_accepted_valid_params)
    assert event.errors["title"].include?("can't be blank")
  end

  test "#create adds error 'is too short (minimum is 8 characters)' to error.title with title less than 8 characters" do
    @min_accepted_valid_params[:title] = "Invaild"
    event = Event.create(@min_accepted_valid_params)
    assert event.errors["title"].include?("is too short (minimum is 8 characters)")
  end

  test "#create adds error 'is too long (maximum is 150 characters)' to error.title with title greater than 150 characters" do
    @min_accepted_valid_params[:title] = ("a" * 151)
    event = Event.create(@min_accepted_valid_params)
    assert event.errors["title"].include?("is too long (maximum is 150 characters)")
  end

  test "#starts adds error 'can't be blank' to error.starts with no starts" do
    @min_accepted_valid_params.delete(:starts)
    event = Event.create(@min_accepted_valid_params)
    assert event.errors["starts"].include?("can't be blank")
  end

  test "#starts adds error 'must occur in the future' if not in the future" do
  @min_accepted_valid_params[:starts]=DateTime.now()
  event = Event.create(@min_accepted_valid_params)
  assert(event.errors[:starts].include?("must occur in the future"))
end

  test "#ends adds error 'can't be blank' to error.ends with no ends" do
    @min_accepted_valid_params.delete(:ends)
    event = Event.create(@min_accepted_valid_params)
    assert event.errors["ends"].include?("can't be blank")
  end

  test "#ends returns error 'must occur after the event starts' if not after starts" do
    @min_accepted_valid_params[:ends] = DateTime.now()
    @min_accepted_valid_params[:starts] = DateTime.now()
    event = Event.create(@min_accepted_valid_params)
    assert(event.errors[:ends].include?("must occur after the event starts"))
  end
end
