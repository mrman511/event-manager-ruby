class HostSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :events
end
