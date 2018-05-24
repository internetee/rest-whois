class TestLogger
  @@log = []

  def self.log
    @@log
  end

  def self.warn(message)
    @@log.push(message)
  end

  def self.info(message = "")
    @@log.push(message)
  end
end
