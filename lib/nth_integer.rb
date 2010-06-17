require 'digest/sha2'

class String
  
  def nth_i n
    scan(/[1-9]/)[n].to_i
  end
  
  def sha
    (Digest::SHA2.new << self).to_s
  end
  
end
  