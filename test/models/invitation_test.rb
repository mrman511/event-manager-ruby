require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @rya = User.create({ email: "rya@volcanomanor.agency", password: "V@l1dPa$5" })
    @volcanomanor = Host.create({ name: "The Volcano Manor", users: [ @rya ] })
    @join_the_recusents = @volcanomanor.create_event({
      title: "Become a Recusant",
      starts: DateTime.now + 4.hours,
      ends: DateTime.now + 6.hours
    })
    @valid_invitation_params = {
      event: @join_the_recusents,
      attending: false,
      max_guests: 0,
      sent_by: @rya
    }
  end

  test "#create creates an invitation in the database" do
    assert_difference("Invitation.count") do
      Invitation.create(@valid_invitation_params)
    end
  end

  test "#create returns an invitation that can be retrieved from the database" do
    created_invitation = Invitation.create(@valid_invitation_params)
    fetched_invitation = Invitation.find(created_invitation.id)
    assert_equal created_invitation, fetched_invitation
  end

  test "#event is required to create an Invitation" do
    @valid_invitation_params.delete(:event)
    assert_no_difference("Invitation.count") do
      Invitation.create(@valid_invitation_params)
    end
  end

  test "#event adds error 'must exist' when not provided" do
    @valid_invitation_params.delete(:event)
    invitation = Invitation.create(@valid_invitation_params)
    assert invitation.errors[:event].include?("must exist")
  end

  test "#sent_by is required to create an Invitation" do
    @valid_invitation_params.delete(:sent_by)
    assert_no_difference("Invitation.count") do
      Invitation.create(@valid_invitation_params)
    end
  end

  test "#sent_by adds error 'must exist' when not provided" do
    @valid_invitation_params.delete(:sent_by)
    invitation = Invitation.create(@valid_invitation_params)
    assert invitation.errors[:sent_by].include?("must exist")
  end

  test "#Invitaions Event.invitations includes created invitaion" do
      invitation = Invitation.create(@valid_invitation_params)
      assert invitation.event.invitations.include?(invitation)
  end
end
