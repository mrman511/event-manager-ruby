class Todo < ApplicationRecord
  validates :title, presence: true, length: { maximum: 25 }
  validates :status, presence: true
  validates :is_completed, inclusion: [ true, false ]
end
