class WhoisRecordsController < ApplicationController
  helper_method :ip_in_whitelist?
  helper_method :contact_form_default_locale
  helper_method :captcha_solved?
  helper_method :disclosure_level

  def show
    domain_name = SimpleIDN.to_unicode(params[:name].to_s).downcase
    @whois_record = WhoisRecord.find_by(name: domain_name)

    @disclosure_level = disclosure_level
    @show_sensitive_data = (@disclosure_level != :public)
    @disclosure_policy_active = DisclosurePolicy.active?
    if @disclosure_policy_active && @disclosure_level != :public
      response.headers['Cache-Control'] = 'private, no-store'
    end
    log_message(params, @whois_record)

    respond_to do |format|
      format.json do
        if @whois_record
          render show_template, status: :ok
        else
          render json: { name: domain_name,
                         error: invalid_data_body(domain_name, json: true) },
                 status: :not_found
        end
      end

      format.html do
        if @whois_record
          render show_template, status: :ok
        else
          render plain: invalid_data_body(domain_name), status: :not_found
        end
      end
    end
  end

  def search
    domain_name = SimpleIDN.to_unicode(params[:domain_name].to_s).downcase
    @whois_record = WhoisRecord.find_by(name: domain_name)

    if @whois_record
      redirect_to whois_record_url(@whois_record.name)
    else
      render plain: invalid_data_body(domain_name), status: :not_found
    end
  end

  private

  def invalid_data_body(domain_name, json: false)
    escaped_domain = CGI.escapeHTML(domain_name)
    prefix = json ? '.' : ": #{escaped_domain}."

    return "Domain not found#{prefix}" if domain_valid_format?(domain_name)

    "Policy error#{prefix} Please study \"Requirements for the " \
    'registration of a Domain Name" of .ee domain regulations. ' \
    'https://www.internet.ee/domains/ee-domain-regulation#registration-of-domain-names'
  end

  def domain_valid_format?(domain_name)
    domain_name_regexp = /\A[a-z0-9\-\u00E4\u00F5\u00F6\u00FC\u0161\u017E]{2,61}\.
    ([a-z0-9\-\u00E4\u00F5\u00F6\u00FC\u0161\u017E]{2,61}\.)?[a-z0-9]{1,61}\z/x

    formatted_domain_name = domain_name.strip.downcase
    (formatted_domain_name =~ domain_name_regexp) != nil
  end

  def log_message(params, whois_record)
    if whois_record
      logger.warn(
        "Requested: #{params[:name]}; " \
        "Record found with id: #{@whois_record.id}; " \
        "Captcha result: #{captcha_solved? ? 'yes' : 'no'}; ip: #{request.remote_ip};"
      )
    else
      logger.warn(
        "Requested: #{params[:name]}; Record not found; " \
        "Captcha result: #{captcha_solved? ? 'yes' : 'no'}; ip: #{request.remote_ip};"
      )
    end
  end

  def ip_in_whitelist?
    return if ENV['whitelist_ip'].blank?

    whitelist = ENV['whitelist_ip'].split(',').map(&:strip)
    whitelist.include?(request.remote_ip)
  end

  def captcha_solved?
    @captcha_solved ||= verify_recaptcha(
      action: 'check',
      minimum_score: 0.5,
      secret_key: ENV['recaptcha_secret_key']
    )
  end

  # Disclosure level under the Domain Regulation 2027 policy, resolved once
  # per request and shared by the HTML and JSON pipelines.
  def disclosure_level
    @disclosure_level ||=
      if ip_in_whitelist?
        :privileged
      elsif captcha_solved?
        :detailed
      else
        :public
      end
  end

  def show_template
    @disclosure_policy_active ? 'whois_records/policy_2027/show' : :show
  end

  def contact_form_default_locale
    :et
  end
end
