class Message
  def self.invalid_param(param, value)
    "#{param} parameter is invalid (#{value})."
  end
end