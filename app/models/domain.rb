class Domain
  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :statuses
  attr_accessor :registered
  attr_accessor :changed
  attr_accessor :expire
  attr_accessor :outzone
  attr_accessor :delete

  def registered?
    statuses.exclude?('deleteCandidate')
  end
end
