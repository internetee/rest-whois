class WhoisRecordsController < ApplicationController
  def show
    # fix id if there is no correct format
    params[:id] = "#{params[:id]}.#{params[:format]}" if !['json', 'html'].include? params[:format]
    @domain_name = SimpleIDN.to_unicode(params[:id].to_s).downcase

    @verified = verify_recaptcha
    @whois_record = WhoisRecord.find_by(name: @domain_name)

    if @whois_record
      Rails.logger.info "Requested: #{params[:id]}; Record found with id: #{@whois_record.id}; Captcha result: #{@verified ? "yes" : "no"}"
    else
      Rails.logger.info "Requested: #{params[:id]}; Record not found; Captcha result: #{@verified ? "yes" : "no"}"
    end

    @client_ip = request.remote_ip
    if @client_ip == ENV['whitelist_ip']
	    @whitelist = true
    end

    begin
      respond_to do |format|
        format.json do
          if @whois_record.present?
                 if @whitelist
                    json =  @whois_record.full_json
                 elsif @verified
                    json =  @whois_record.full_json
                 else
                    json =  @whois_record.public_json
                 end
            return render json: json
          else
            return render json: {
              name: @domain_name,
              error: "Domain not found."},
              status: :not_found
          end
        end
      end
    rescue ActionController::UnknownFormat
      if @whois_record.present?
      else
        return render text: "Domain not found: #{CGI::escapeHTML @domain_name}", status: :not_found
      end
    end
  end
end
