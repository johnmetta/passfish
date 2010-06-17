require 'digest/sha2'
require 'base64'
require 'lib/nth_integer'
require 'lib/wheel_of_fortune'

class Hasher  
  include WheelOfFortune  
  def initialize str
    # 26 characters + 10 numerals + 26 punctuation marks equals
    # 2.2e14 combinations for an 8 character sequence
    # Add uppercase characters and you have 3.6e15 combinations.
    @word = str
    @base64 = base64_hash
    @letters = %w{A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
    # Generate spin indexes from the hash using the answer to the ultimate
    # question in the universe
    spin = []
    [0,4,2].each do |i|
      spin << @base64.to_s.nth_i(i)
    end
    @chars   = spin(%w{! @ # $ % ^ & * ( ) _ - + = [ ] | / ? : ; < > , . ~}, spin)
  end    
  
  def base64_hash
    #We want enough length, so we create a SHA hash of the string, then
    # convert that to Base64 to increase the character variation
    # Note: We strip the trailing equal signs and newline from the string.
    Base64.encode64(@word.sha)[0..-4]
  end

  def noise; @noise ||= get_noise; end
  def hash; @hash ||= make_noisy_hash; end

  def get_noise
    # create a dictionary of letter to number swaps
    noise = {}
    @letters.each_with_index do |l,i|
      noise[l] = @chars[i]
    end
    noise
  end
  
  def make_noisy_hash
    str = @base64
    seen = [] #how many times have we seen a character?
    index = 0 #Just store a number that'll always be the same to use as an index
    # split the hash and replace every other value with the values from noise and update the
    # index value if it's an integer. This merely takes the given hash and adds some entropy
    # to it in a repeatable way
    str.split('').each_with_index do |ch, i|
      if seen.count(ch) % 2 == 0 
        str[i] = noise[ch] ? noise[ch] : ch
      end
      seen << ch
    end
    # return a @length long string starting at the index given by the last integer in the hash
    # This is the password that is secure with high (psuedo-)entropy, but which can be regenerated
    # given all the necessary information.
    str
  end
  
  def is_numeric? s
    begin
      Float(s)
    rescue
      false # not numeric
    else
      true # numeric
    end
  end

end

if __FILE__ == $0
  hasher = Hasher.new "mettadorea"
  p hasher.hash
end
