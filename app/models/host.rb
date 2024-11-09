class Host < ApplicationRecord
  has_many :events
  has_many :hostings
  has_many :users, through: :hostings

  validates :name, presence: true
  # validates :users, presence: true
  validate :validate_users_not_empty

  def add_user(new_user)
    if new_user && new_user.instance_of?(User)
      validate_unique_user(new_user)
      self.users.push(new_user)
    else
      raise Exception.new "No valid user provided"
    end
  end

  def remove_user(removee)
    hosting = validate_remove_user(removee)
    if self.users.count == 1
      raise Exception.new "Cannot delete the last user from host"
    end
    hosting.destroy()
  end

  def create_event(event_params)
    if event_params
      event_params["host"] = self
      @new_event = Event.new(event_params)
      if can_validate_created_event()
        @new_event.save!
        add_new_event()
      end
      return @new_event
    end
    raise Exception.new "Event params are required"
  end

  def delete_event(event_id)
    if !event_id
      raise Exception.new "No event requested for removal"
    end
    self.events.each do |comparison_event|
      if comparison_event.id == event_id.to_i
        comparison_event.destroy()
        return
      end
    end
    raise Exception.new "Event not found"
  end

  private

  def validate_remove_user(removee)
    if removee && removee.instance_of?(User)
      self.hostings.each do |hosting, i|
        if hosting.user_id == removee.id
          return hosting
        end
      end
      raise Exception.new "User is not a member of host users"
    end
    raise Exception.new "Invalid user provided"
  end

  def validate_unique_user(new_user)
    if self.users.any? { |comparison_user| comparison_user.id == new_user.id }
      raise Exception.new "User is already a host"
    end
  end

  def validate_users_not_empty
    if !self.users or self.users.empty?
      errors.add(:users, "User required to create host")
    end
  end

  def add_new_event
    if self.events.count == 0
      self.events = [ @new_event ]
    else
      self.events.push(@new_event)
    end
  end

  def can_validate_created_event
    self.events.each do |comparison_event|
      validate_new_event_starts_time(comparison_event)
      validate_current_event_start_times(comparison_event)
    end
    if @new_event.valid?
      true
    else
      false
    end
  end

  def validate_new_event_starts_time(comparison_event)
    if @new_event.starts >= comparison_event.starts && @new_event.starts < comparison_event.ends
      raise Exception.new "Added event conflicts with another hosted Event"
    end
  end

  def validate_current_event_start_times(comparison_event)
    if comparison_event.starts >= @new_event.starts && comparison_event.starts < @new_event.ends
      raise Exception.new "Added event conflicts with another hosted Event"
    end
  end
end
