class Invitation < ApplicationRecord
  belongs_to :sent_by, class_name: "User"
  belongs_to :event

  validates :sent_by, presence: true
end
