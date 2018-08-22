module Naming
  extend self

  def filename(string)
    return string.to_s.downcase.gsub(/[^0-9A-Za-z.\-]/, '_') unless string.nil?
  end

end