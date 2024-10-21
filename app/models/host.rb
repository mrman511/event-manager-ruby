class Host < ApplicationRecord
  has_many :events
  validates :name, presence: true

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
      if comparison_event.id === event_id
        comparison_event.destroy()
        return
      end
    end
    raise Exception.new "Event not found"
  end

  private

  def add_new_event()
    if self.events.count === 0
      self.events = [@new_event]
    else
      self.events.push(@new_event)
    end
  end

  def can_validate_created_event()
    self.events.each do |comparison_event|
      validate_new_event_starts_time(comparison_event)
      validate_current_event_start_times(comparison_event)
    end
    if @new_event.valid?
      return true
    else
      return false
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
