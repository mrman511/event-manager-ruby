require "test_helper"

class TodoTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      title: "An excellent todo",
      status: "created",
      is_completed: false
    }
  end

  test "#create! creates a todo that can be fetched from the database" do
    created_todo = Todo.create!(@valid_attributes)
    fetched_todo = Todo.find(created_todo.id)

    assert_equal @valid_attributes[:title], fetched_todo.title
    assert_equal @valid_attributes[:status], fetched_todo.status
    assert_equal @valid_attributes[:is_completed], fetched_todo.is_completed
  end

  test "#title is required to create a new todo" do
    assert_raises { Todo.create!(@valid_attributes.delete(:title)) }
  end

  test "#title cannot create a todo with a title over 25 characters" do
    extra_long_title = "A" * 26
    @valid_attributes[:title] = extra_long_title

    assert_raises { Todo.create!(@valid_attributes) }
  end

  test "#status is required to create a new todo" do
    assert_raises { Todo.create!(@valid_attributes.delete(:status)) }
  end

  test "#is_completed is required to create a new todo" do
    assert_raises { Todo.create!(@valid_attributes.delete(:is_completed)) }
  end
end
