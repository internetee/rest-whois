class Contact
  attr_reader :name
  attr_reader :type
  attr_reader :email
  attr_reader :last_update

  def initialize(name:, type:, email:, last_update:)
    @name = name
    @type = type
    @email = email
    @last_update = last_update
  end

  def ==(other)
    name == other.name &&
      type == other.type &&
      email == other.email &&
      last_update == other.last_update
  end
end
