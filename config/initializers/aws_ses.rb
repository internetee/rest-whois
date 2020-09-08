aws_ses_base = AWS::SES::Base.new(
  access_key_id: ENV['aws_ses_access_key_id'],
  secret_access_key: ENV['aws_ses_secret_access_key'],
  server: ENV['aws_ses_server'],
  message_id_domain: ENV['aws_ses_message_id_domain']
)

ActionMailer::Base.add_delivery_method :aws_ses, aws_ses_base
