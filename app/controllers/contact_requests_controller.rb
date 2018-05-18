class ContactRequestsController < ApplicationController
  before_action :set_contact_request, only: [:edit, :update, :show]
  before_action :check_for_replay, only: [:edit, :update, :show]

  def new
    whois_record = WhoisRecord.find_by!(name: params[:domain])
    @contact_request = ContactRequest.new(whois_record: whois_record)
  end

  def create
    @contact_request = ContactRequest.new(contact_request_params)

    if @contact_request.save
      @contact_request.send_confirmation_email
      redirect_to(:root, notice: I18n.t('contact_requests.successfully_created'))
    else
      render(:new)
    end
  end

  def show
    if @contact_request.confirm_email
      redirect_to edit_contact_request_path
    end
  end

  def edit
  end

  def update
    set_contact_request
    email_body = params[:email_body]

    if @contact_request.send_email(email_body)
     redirect_to(@contact_request, notice: I18n.t('contact_requests.successfully_created'))
    end
  end

  private

  def set_contact_request
    @contact_request = ContactRequest.find_by_secret(params[:secret])
  end

  def check_for_replay
    if @contact_request.completed_or_expired?
      return head(:forbidden)
    end
  end

  def contact_request_params
    params.require(:contact_request).permit(:email, :whois_record_id)
  end
end
