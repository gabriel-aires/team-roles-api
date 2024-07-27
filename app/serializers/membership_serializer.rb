class MembershipSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :team_id

  belongs_to :role
end
