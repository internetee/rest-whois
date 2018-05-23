class WhoisRecordsController < ApplicationController
  def show
    domain_name = SimpleIDN.to_unicode(params[:id].to_s).downcase
    @whois_record = WhoisRecord.find_by(name: domain_name)

    set_captcha_and_whitelist
    log_message(params, @whois_record)

    respond_to do |format|
      format.json do
        if @whois_record
          render :show, status: :ok
        else
          render json: { name: domain_name, error: "Domain not found." },
                 status: :not_found
        end
      end

      format.html do
        if @whois_record
          render :show, status: :ok
        else
          render text: "Domain not found: #{CGI::escapeHTML(domain_name)}",
                 status: :not_found
        end
      end
    end
  end

  private

  def set_captcha_and_whitelist
    @whitelist = true if request.remote_ip == ENV['whitelist_ip']

    @verified = verify_recaptcha if request.format == 'html'
  end

  def log_message(params, whois_record)
    if whois_record
      Rails.logger.warn(
        "Requested: #{params[:id]}; " \
        "Record found with id: #{@whois_record.id}; " \
        "Captcha result: #{@verified ? 'yes' : 'no'}; ip: #{request.remote_ip};"
      )
    else
      Rails.logger.warn(
        "Requested: #{params[:id]}; Record not found; " \
        "Captcha result: #{@verified ? 'yes' : 'no'}; ip: #{request.remote_ip};"
      )
    end
  end
end
