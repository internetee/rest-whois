class WhoisRecordsController < ApplicationController
  def show
    # fix id if there is no correct format
    params[:id] = "#{params[:id]}.#{params[:format]}" if !['json', 'html'].include? params[:format]
    @domain_name = SimpleIDN.to_unicode(params[:id].to_s).downcase

    @verified = verify_recaptcha
    @whois_record = WhoisRecord.find_by(name: @domain_name)

    begin
      respond_to do |format|
        format.json do
          if @whois_record.present?
            json = @verified ? @whois_record.full_json : @whois_record.public_json
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
