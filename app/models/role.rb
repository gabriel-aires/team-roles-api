class Role < ApplicationRecord
  has_many :memberships

  validates :name, presence: true, uniqueness: true
  validate :ensure_default_role_exists

  after_save :update_default_role

  def ensure_default_role_exists
    return if self.is_default
    
    unless Role.where(is_default: true).where.not(id: self.id).exists?
      errors.add(:base, "There must be a default role")
    end
  end

  def update_default_role
    return unless saved_change_to_attribute?(:is_default)

    Role.where.not(id: self.id).update_all(is_default: false) if self.is_default
  end
end
