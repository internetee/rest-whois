class ContactRequest < ActiveRecord::Base
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
    save
  end

  def confirm_email
    return unless confirmable?

    self.status = STATUS_CONFIRMED
    save
  end

  def completed_or_expired?
    status == STATUS_SENT || !still_valid?
  end

  private

  def extract_emails_for_recipients(recipients)
    emails = []
    if recipients.include?('admin_contacts')
      emails << whois_record.json['email']
    end

    recipients.map do |recipient_type|
      whois_record.json[recipient_type].each do |recipient|
        emails << recipient['email']
      end
    end

    emails
  end

  def sendable?
    status == STATUS_CONFIRMED && still_valid?
  end

  def confirmable?
    status == STATUS_NEW && still_valid?
  end

  def still_valid?
    valid_to >= Time.now
  end

  def create_random_secret
    self.secret = SecureRandom.hex(64)
  end

  def set_valid_to_at_24_hours_from_now
    self.valid_to = (Time.now + 24.hours)
  end
end
