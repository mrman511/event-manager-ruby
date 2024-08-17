require "rails_helper"

RSpec.describe "Todo Model", type: :model do
  it "Is valid with valid attributes" do
    expect(Todo.new).to be_valid
  end
end
