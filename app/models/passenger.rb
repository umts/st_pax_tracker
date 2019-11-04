# frozen_string_literal: true

class Passenger < ApplicationRecord
  validates :name,  presence: true, length: { maximum: 50 }
  validates :registration_date, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  STATUSES = %w[Alumni Faculty Staff Student].freeze
  validates :status, inclusion: { in: STATUSES, allow_blank: true }
  validates :spire, uniqueness: true,
                    format: { with: /\A\d{8}@umass.edu\z/,
                              message: 'must be 8 digits followed by @umass.edu' }

  belongs_to :registerer, foreign_key: :registered_by, class_name: 'User',
                          optional: true

  enum active_status: { pending: 0, active: 1, archived: 2 }

  scope :permanent, -> { where(permanent: true) }
  scope :temporary, -> { where.not(permanent: true) }

  has_one :doctors_note, dependent: :destroy
  accepts_nested_attributes_for :doctors_note

  belongs_to :mobility_device, optional: true

  attr_accessor :needs_assistance

  before_save do
    if needs_assistance
      self.note = 'Needs additional assistance getting to/from buildings'
    end
  end

  before_validation :assign_registration_date

  def expiration_display
    return if permanent?

    doctors_note.try(:expiration_date).try :strftime, '%m/%d/%Y' || 'No Note'
  end

  def needs_longer_rides?
    mobility_device&.needs_longer_rides?.present?
  end

  def needs_doctors_note?
    return false if permanent?

    recently_registered = registration_date >= 3.business_days.ago
    doctors_note&.expired_within_grace_period? ||
    (doctors_note.blank? && recently_registered)
  end

  def rides_expired?
    return false if permanent?

    registration_expired = registration_date < DoctorsNote.grace_period
    registration_expired && (doctors_note.nil? || doctors_note.expired?)
  end

  def rides_expire
    return if permanent?

    if doctors_note.present?
      return 3.business_days.after(doctors_note.expiration_date)
    end
    return 3.business_days.since(registration_date) if persisted?

    3.business_days.from_now
  end

  def temporary?
    !permanent?
  end

  def toggle_status(desired_status)
    case desired_status
    when 'active' then active!
    when 'archived' then update_attribute(:active_status, 'archived')
    when 'pending' then pending!
    end
  end

  private

  def assign_registration_date
    if active_status_changed? && active?
      assign_attributes(registration_date: Time.zone.today)
    elsif registration_date.blank?
      assign_attributes(registration_date: (created_at || Time.zone.today))
    end
  end
end
