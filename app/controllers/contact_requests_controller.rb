class ContactRequestsController < ApplicationController
  before_action :set_contact_request, only: %i[edit update show]
  before_action :check_for_replay, only: %i[edit update show]
  before_action :set_ip_address, only: [:update]

  def new
    whois_record = WhoisRecord.find_by!(name: params[:domain_name])
    raise ActiveRecord::RecordNotFound unless whois_record.contactable?
    @contact_request = ContactRequest.new(whois_record: whois_record)
  end

  def create
    @contact_request = ContactRequest.new(contact_request_params)

    if @contact_request.save
      @contact_request.send_confirmation_email
      logger.warn("Confirmation request email registered to #{@contact_request.email}" \
        " (IP: #{request.ip})")
      redirect_to(:root, notice: I18n.t('contact_requests.successfully_created'))
    else
      render(:new)
    end
  rescue Net::SMTPServerBusy
    redirect_to(:root, error: I18n.t('contact_requests.smtp_error'))
  end

  def show
    redirect_to edit_contact_request_url if @contact_request.confirm_email
  end

  def edit; end

  def update
    email_body = params[:email_body]
    recipients = params[:recipients]

    if @contact_request.send_contact_email(body: email_body, recipients: recipients)
      logger.warn(
        "Email sent to #{@contact_request.whois_record.name} contacts " \
        "from #{@contact_request.email} (IP: #{request.ip})"
      )
      redirect_to(:root, notice: I18n.t('contact_requests.successfully_sent'))
    else
      redirect_to(:root, error: I18n.t('contact_requests.something_went_wrong'))
    end
  end

  private

  def set_contact_request
    @contact_request = ContactRequest.find_by(secret: params[:secret])
  end

  def set_ip_address
    @contact_request.ip_address = request.ip
    @contact_request.save
  end

  def check_for_replay
    return unless @contact_request.completed_or_expired?
    raise ActiveRecord::RecordNotFound
  end

  def contact_request_params
    params.require(:contact_request).permit(:email, :whois_record_id, :name)
  end
end
