class Membership < ApplicationRecord
  belongs_to :role

  validates :user_id, :team_id, :role_id, :role, presence: true
  validates :user_id, uniqueness: { scope: :team_id, message: "already has a role in this team" }

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= Role.find_by(is_default: true)
  end
end
