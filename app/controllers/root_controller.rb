class RootController < ApplicationController
  before_action :index, :set_params

  def index

    domain_name = params.dig(:whois_record, :domain_name)
    whois_record = WhoisRecord.find_by(name: domain_name)
    if whois_record
      redirect_to(whois_record, name: whois_record.name)
    end
  end

  private

  def set_params
    params.permit(:whois_record).permit(:domain_name)
  end
end
