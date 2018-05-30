class WhoisRecordsController < ApplicationController
  helper_method :ip_in_whitelist?
  helper_method :contact_form_default_locale

  def show
    domain_name = SimpleIDN.to_unicode(params[:name].to_s).downcase
    @whois_record = WhoisRecord.find_by(name: domain_name)

    @show_sensitive_data = (ip_in_whitelist? || captcha_solved?)
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

  def search
    domain_name = SimpleIDN.to_unicode(params[:domain_name].to_s).downcase
    @whois_record = WhoisRecord.find_by(name: domain_name)

    if @whois_record
      redirect_to "/v1/#{@whois_record.name}"
    else
      render text: "Domain not found: #{CGI::escapeHTML(domain_name)}",
             status: :not_found
    end
  end

  private

  def log_message(params, whois_record)
    if whois_record
      Rails.logger.warn(
        "Requested: #{params[:name]}; " \
        "Record found with id: #{@whois_record.id}; " \
        "Captcha result: #{captcha_solved? ? 'yes' : 'no'}; ip: #{request.remote_ip};"
      )
    else
      Rails.logger.warn(
        "Requested: #{params[:name]}; Record not found; " \
        "Captcha result: #{captcha_solved? ? 'yes' : 'no'}; ip: #{request.remote_ip};"
      )
    end
  end

  def ip_in_whitelist?
    return unless ENV['whitelist_ip'].present?
    whitelist = ENV['whitelist_ip'].split(',').map(&:strip)
    whitelist.include?(request.remote_ip)
  end

  def captcha_solved?
    verify_recaptcha
  end

  def contact_form_default_locale
    :et
  end
end
