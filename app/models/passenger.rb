class Passenger < ApplicationRecord
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }, uniqueness: true

  scope :permanent, -> { where(permanent: true) }
  scope :temporary, -> { where(permanent: false) }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  has_one :doctors_note

  # TODO: Make configurable by user
  MOBILITY_DEVICES = ['Boot', 'Crutches', 'Cane', 'Walker',
                      'Service Dog'].freeze

  
end
