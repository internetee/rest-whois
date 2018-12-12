class Contact
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :type
  attr_accessor :reg_number
  attr_accessor :email
  attr_accessor :ident_country
  attr_accessor :last_update

  def private_person?
    !legal_person?
  end

  def legal_person?
    type == 'org'
  end
end
