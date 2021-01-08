class ApplicationMailer < ActionMailer::Base
  default from: ENV['mailer_from_address']
  layout 'mailer'

  def self.ses_configured?
    ses ||= Aws::SES::Client.new
    ses.config.credentials.access_key_id.present?
  rescue Aws::Errors::MissingRegionError
    false
  end
end
