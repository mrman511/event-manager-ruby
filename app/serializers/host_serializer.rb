class HostSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :events
  has_many :users
end
