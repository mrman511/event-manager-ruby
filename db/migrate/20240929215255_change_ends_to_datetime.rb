class ChangeEndsToDatetime < ActiveRecord::Migration[7.2]
  def change
    change_column :events, :ends, :datetime
  end
end
