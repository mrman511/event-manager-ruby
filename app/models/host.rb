class Host < ApplicationRecord
  has_many :events

  # def new_event_start_conflict(new_event, event){
  #   # test
  #   if event.ends
  #     ends = event.ends
  #     # test
  #   else
  #     # test
  #     ends = event.starts + 24.hours
  #   end

  #   if new_event.starts >= event.starts && new_event.
  # }
  
  def add_event(new_event)
    if new_event
      if self.events == nil
        self.events = [new_event]
      end
      if self.events
        self.events.push(new_event)
      end
      self.save
    end
  end
end
