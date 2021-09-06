class Contact
  include ActiveModel::Model

  attr_accessor :name, :type, :reg_number, :email, :ident_country,
                :last_update, :disclosed_attributes

  def private_person?
    !legal_person?
  end

  def legal_person?
    type == 'org'
  end

  def attribute_disclosed?(attribute)
    # It is needed for compatibility with old records, which have no such key.
    # And even though `registry` app generates it for every record ([] for the ones having 0), it
    # may take some time until all WHOIS records are regenerated.
    return unless disclosed_attributes

    disclosed_attributes.include?(attribute.to_s)
  end
end
