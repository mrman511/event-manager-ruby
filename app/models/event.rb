class Event < ApplicationRecord
  belongs_to :host
  validates :title, presence: true, length: { minimum: 8, maximum: 150 }
  validates :starts, presence: true
  validates :ends, presence: true

  validate :starts_in_future
  validate :ends_after_starts

  private

  def starts_in_future
    if starts && starts <= DateTime.now()
      errors.add(:starts, "must occur in the future")
    end
  end

  def ends_after_starts
    if ends && starts
      if starts >= ends
        errors.add(:ends, "must occur after the event starts")
      end
    end
  end
end
