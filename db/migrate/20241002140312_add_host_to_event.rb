class AddHostToEvent < ActiveRecord::Migration[7.2]
  def change
    add_reference :events, :host, null: false, foreign_key: true
  end
end
