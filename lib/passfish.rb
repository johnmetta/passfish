#!/usr/bin/env ruby
# == Synopsis 
#   A password manager-like thingy that generates secure passwords that you can find later
#
# == Examples
#   This 
#     ruby_cl_skeleton foo.txt
#
#   Other examples:
#     ruby_cl_skeleton -q bar.doc
#     ruby_cl_skeleton --verbose foo.html
#
# == Usage 
#   ruby_cl_skeleton [options] source_file
#
#   For help use: ruby_cl_skeleton -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#   TO DO - add additional options
#
# == Author
#   YourName
#
# == Copyright
#   Copyright (c) 2007 YourName. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'lib/passfish'
require 'digest/sha2'
require 'etc'
require 'openssl'
class Passfish
  attr_accessor :key, :passphrase, :name, :identifier, :length
  def initialize identifier, options = {}
    @home = Etc.getpwuid.dir
    @passfishdir = '.passfish'
    @keyfile = 'private.pem'
    @keypath = File.join(@home, @passfishdir, @keyfile)
    @identifier = identifier
    raise "You need an identifier to generate a password" if not @identifier
    @key = get_key options[:key]
    @passphrase = options[:passphrase] || ''
    @name = options[:name] || ''
    @length = options[:length] || 8
    @noise = {'a' => '@',
             'b' => '(',
             'c' => ')',
             'd' => '&',
             'e' => '%',
             'f' => '!',
             '1' => '/',
             '2' => '|',
             '3' => '#',
             '4' => '*',
             '5' => '?',
             '6' => '$',
             '8' => '+',
             '9' => '^'}
  end

  def get_key key
    begin
      key || File.read(@keypath)
    rescue
      generate_and_read_keyfile make_rsa_key
    end
  end
  
  def make_rsa_key; OpenSSL::PKey::RSA.new(2048); end

  def generate_and_read_keyfile rsa_key
      puts "Cowardly refusing to generate a password without a key!! You need to specify a keyfile using the
      -k parameter. Create a keyfile that contains some text (like an RSA 
      key or a chapter from a book) and set the file with 600 permissions (readable only by you). I won't 
      check if it's an empty file or has open permissions-- that's up to you. But your password will be 
      SUPER easy to figure out if that's the case. You've been warned\n

      For now, I've generated the file in ~/.passfish/private.pem (the default location) and am using that
      file. If you change or loose this, any password generated that uses it will change. So, if you think
      you want to change it, do it now, and then regenerate this password."

      # make ~/.passfish if it doesn't exist
      FileUtils.mkdir File.join(@home, @passfishdir), :mode => 0700 if not File.directory? File.join(@home, @passfishdir)
      # Write RSA key to file, and read it back to @key using the same command we use in set_key!
      File.open(@keypath, 'w') {|f| f.write(rsa_key) }
      File.read(@keypath)
  end

  def make_hash_string; (Digest::SHA2.new << combine_params).to_s; end

  def combine_params; @identifier + @key + @name + @passphrase; end

  def generate
    str = make_hash_string
    seen = [] #how many times have we seen a character?
    index = 0 #Just store a number that'll always be the same to use as an index

    # split the hash and replace every other value with the values from noise and update the
    # index value if it's an integer. This merely takes the given hash and adds some entropy
    # to it in a repeatable way
    str.split('').each_with_index do |ch, i|
      if seen.count(ch) % 2 == 0
        str[i] = @noise[ch] ? @noise[ch] : ch
      end
      seen << ch
      index = ch.to_i if is_numeric? ch
    end
    # return a @length long string starting at the index given by the last integer in the hash
    # This is the password that is secure with high (psuedo-)entropy, but which can be regenerated
    # given all the necessary information.
    str[index...(index + @length)]
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

