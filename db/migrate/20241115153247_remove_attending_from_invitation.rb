class RemoveAttendingFromInvitation < ActiveRecord::Migration[7.2]
  def change
    remove_column :invitations, :attending
  end
end
