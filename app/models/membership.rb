class Membership < ApplicationRecord
  belongs_to :role, optional: true

  after_initialize :set_default_role, if: :new_record?

  def set_default_role
    self.role ||= Role.find_by(is_default: true)
  end
end
