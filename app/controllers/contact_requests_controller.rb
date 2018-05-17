class ContactRequestsController < ApplicationController
  def new
    whois_record = WhoisRecord.find_by!(name: params[:domain])
    @contact_request = ContactRequest.new(whois_record: whois_record)
  end

  def create
    @contact_request = ContactRequest.new(contact_request_params)

    if @contact_request.save
      redirect_to(@contact_request, notice: I18n.t('contact_requests.successfully_created'))
    else
      render(:new)
    end
  end

  def edit
  end

  def show
  end

  def contact_request_params
    params.require(:contact_request).permit(:email, :whois_record_id)
  end
end
