class User < ApplicationRecord
  validates :name, :email, :spire, presence: true

  scope :dispatchers, -> { where.not admin: true }

  def can_delete?(item)
    admin? || (item.is_a?(LogEntry) && item.user == self)
  end

  def dispatcher?
    !admin?
  end
end
