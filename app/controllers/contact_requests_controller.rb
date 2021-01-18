class ContactRequestsController < ApplicationController
  before_action :set_contact_request, only: %i[edit update show]
  before_action :check_for_replay, only: %i[edit update show]

  rescue_from ActionController::UnknownFormat do
    logger.warn("The unlucky customer was using format of: #{request.format}")
    raise
  end

  def new
    whois_record = WhoisRecord.find_by!(name: params[:domain_name])
    raise ActiveRecord::RecordNotFound unless whois_record.contactable?

    @contact_request = ContactRequest.new(whois_record: whois_record)
  end

  def create
    @contact_request = ContactRequest.new(contact_request_params)
    result = @contact_request.save_to_registry
    @contact_request = result ? ContactRequest.find_by(id: result['id']) : nil
    if @contact_request
      update_request_secret
      @contact_request.send_confirmation_email
      @contact_request.reload
      logger.warn("Confirmation request email registered to #{@contact_request.email}" \
        " (IP: #{request.ip})")
      render :confirmation_completed
    else
      redirect_to(:root_url, alert: t('contact_requests.registry_link_error'))
    end
  rescue Net::SMTPServerBusy => e
    logger.warn("Failed confirmation request email to #{@contact_request.email}. #{e.message}")
    redirect_to(:root, alert: t('contact_requests.smtp_error'))
  end

  def redirect_to_main
    referer = ENV.fetch('main_page_url') { root_url }
    respond_to do |format|
      format.html { redirect_to referer }
    end
  end

  def show
    if @contact_request.confirmable?
      redirect_to edit_contact_request_url
    else
      redirect_to root_url, alert: t('contact_requests.already_used')
    end
  end

  def edit; end

  def update
    email_body = params[:email_body]
    recipients = params[:recipients] || ['admin_contacts']
    recipients << 'admin_contacts' unless recipients.include?('admin_contacts')
    @contact_request.confirm_email(ip: request.ip)
    @contact_request.reload
    if @contact_request.send_contact_email(body: email_body, recipients: recipients, ip: request.ip)
      logger.warn(
        "Email sent to #{@contact_request.whois_record.name} contacts " \
        "from #{@contact_request.email} (IP: #{request.ip})"
      )

      render :request_completed
    else
      redirect_to(:root, alert: t('contact_requests.something_went_wrong'))
    end
  end

  private

  def set_contact_request
    @contact_request = ContactRequest.find_by(secret: params[:secret])
  end

  def update_request_secret
    @contact_request.update(secret: SecureRandom.hex(64)) if Rails.env == 'test'
  end

  def check_for_replay
    return unless @contact_request.completed_or_expired?

    raise ActiveRecord::RecordNotFound
  end

  def contact_request_params
    params.require(:contact_request).permit(:email, :whois_record_id, :name)
  end
end
