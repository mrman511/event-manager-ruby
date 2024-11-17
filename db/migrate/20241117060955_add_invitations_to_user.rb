class AddInvitationsToUser < ActiveRecord::Migration[7.2]
  def change
    def change
      add_reference :invitations, :user, null: true, foreign_key: true
    end
  end
end
