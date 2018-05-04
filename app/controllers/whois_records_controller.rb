class WhoisRecordsController < ApplicationController
  def show
    # fix id if there is no correct format
    params[:id] = "#{params[:id]}.#{params[:format]}" if !['json', 'html'].include? params[:format]
    @domain_name = SimpleIDN.to_unicode(params[:id].to_s).downcase

    # TODO: Extract
    if request.format == 'html'
      @verified = verify_recaptcha
    end
    @whois_record = WhoisRecord.find_by(name: @domain_name)
    @client_ip = request.remote_ip

    if @whois_record
      Rails.logger.warn "Requested: #{params[:id]}; Record found with id: #{@whois_record.id}; Captcha result: #{@verified ? "yes" : "no"}; ip: #{@client_ip};"
    else
      Rails.logger.warn "Requested: #{params[:id]}; Record not found; Captcha result: #{@verified ? "yes" : "no"}; ip: #{@client_ip};"
    end

    # TODO: Extract
    if @client_ip == ENV['whitelist_ip']
	    @whitelist = true
    end
  end
end
