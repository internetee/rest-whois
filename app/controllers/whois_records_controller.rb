class WhoisRecordsController < ApplicationController
  def show
    # fix id if there is no correct format
    params[:id] = "#{params[:id]}.#{params[:format]}" if !['json', 'html'].include? params[:format]
    @verified = verify_recaptcha
    @whois_record = WhoisRecord.find_by(name: params[:id])

    begin
      respond_to do |format|
        format.json do
          if @whois_record.present?
            json = @verified ? @whois_record.full_json : @whois_record.public_json
            return render json: json
          else
            return render json: {
              name: params[:id],
              error: "Domain not found."},
              status: :not_found
          end
        end
      end
    rescue ActionController::UnknownFormat
      if @whois_record.present?
      else
        return render text: "Domain not found: #{params[:id]}", status: :not_found
      end
    end
  end
end
