class ContactRequest < ApplicationRecord
  def self.connect_to_write_database_if_defined
    return unless Rails.configuration.database_configuration["write_#{Rails.env}"]
    establish_connection "write_#{Rails.env}".to_sym
  end

  connect_to_write_database_if_defined

  STATUS_NEW       = 'new'.freeze
  STATUS_CONFIRMED = 'confirmed'.freeze
  STATUS_SENT      = 'sent'.freeze
  STATUSES         = [STATUS_NEW, STATUS_CONFIRMED, STATUS_SENT].freeze

  belongs_to :whois_record

  validates :whois_record, presence: true
  validates :email, presence: true
  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  attr_readonly :secret,
                :valid_to

  before_create do
    create_random_secret
    set_valid_to_at_24_hours_from_now
  end

  def send_confirmation_email
    ContactRequestMailer.confirmation_email(self).deliver_now
  end

  def send_contact_email(body: '', recipients: [])
    return unless mark_as_sent
    recipients_emails = extract_emails_for_recipients(recipients)
    return if recipients_emails.empty?

    ContactRequestMailer.contact_email(
      contact_request: self,
      recipients: recipients_emails,
      mail_body: body
    ).deliver_now

    self
  end

  def mark_as_sent
    return unless sendable?
    self.status = STATUS_SENT
    save!
  end

  def confirm_email
    return unless confirmable?

    self.status = STATUS_CONFIRMED
    save
  end

  def completed_or_expired?
    status == STATUS_SENT || !still_valid? || !whois_record_exists?
  end

  private

  def extract_emails_for_recipients(recipients)
    emails = []
    emails << whois_record.json['email'] if recipients.include?('admin_contacts')

    recipients.map do |recipient_type|
      whois_record.json[recipient_type].each do |recipient|
        emails << recipient['email']
      end
    end

    emails.uniq
  end

  def sendable?
    status == STATUS_CONFIRMED && still_valid? && whois_record_exists?
  end

  def confirmable?
    status == STATUS_NEW && still_valid? && whois_record_exists?
  end

  def still_valid?
    valid_to >= Time.zone.now
  end

  def whois_record_exists?
    whois_record.present?
  end

  def create_random_secret
    self.secret = SecureRandom.hex(64)
  end

  def set_valid_to_at_24_hours_from_now
    self.valid_to = (Time.zone.now + 24.hours)
  end
end
