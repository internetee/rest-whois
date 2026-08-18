class ContactRequestsController < ApplicationController
  before_action :set_contact_request, only: %i[edit update show]
  before_action :check_for_replay, only: %i[edit update show]

  MAX_SYNC_WAIT_TIME = 5 # seconds

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

    unless result
      redirect_to(:root, alert: t('contact_requests.registry_link_error'))
      return
    end

    @contact_request = fetch_contact_request(result)
    process_contact_request
  rescue Net::SMTPServerBusy => e
    handle_smtp_error(e)
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

    unless confirm_contact_request
      redirect_to(:root, alert: t('contact_requests.registry_link_error'))
      return
    end

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

  # A repeated submit of the same form is legitimate - the one-time link is burned only once the
  # request reaches the 'sent' status (see #check_for_replay). So an already confirmed request is
  # not an error, and a falsy answer here really does mean the registry refused the update.
  def confirm_contact_request
    return true if @contact_request.status == ContactRequest::STATUS_CONFIRMED

    @contact_request.confirm_email(ip: request.ip)
  end

  # The registry saved the record into its own database, and it reaches ours with replication
  # delay, so poll for a while. If it is still not there, build the record from the answer the
  # registry has just given us - it holds everything the confirmation email needs. Telling the
  # user that the registry is unreachable would be plain wrong: the request has been created.
  def fetch_contact_request(result)
    start_time = Time.now
    while Time.now - start_time < MAX_SYNC_WAIT_TIME
      contact_request = ContactRequest.find_by(id: result['id'])
      return contact_request if contact_request

      sleep(0.5) # Sleep for 0.5 seconds before retrying
    end

    logger.warn("Contact request #{result['id']} is not visible in the local database after " \
      "#{MAX_SYNC_WAIT_TIME}s, falling back to the registry answer")
    ContactRequest.new(result.slice(*ContactRequest.column_names))
  end

  def process_contact_request
    update_request_secret
    @contact_request.send_confirmation_email
    logger.warn("Confirmation request email registered to #{@contact_request.email}" \
      " (IP: #{request.ip})")
    render :confirmation_completed
  end

  def handle_smtp_error(exception)
    logger.warn("Failed confirmation request email to #{@contact_request.email}. #{exception.message}")
    redirect_to(:root, alert: t('contact_requests.smtp_error'))
  end
end
