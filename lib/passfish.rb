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

require 'lib/hasher'
require 'lib/wheel_of_fortune'
require 'digest/sha2'
require 'etc'
require 'openssl'

class Passfish
  include WheelOfFortune
  attr_accessor :key, :passphrase, :name, :identifier, :length
  def initialize identifier, options = {}
    @home = Etc.getpwuid.dir
    @passfishdir = '.passfish'
    @keyfile = 'private.pem'
    @keypath = File.join(@home, @passfishdir, @keyfile)
    @identifier = identifier
    raise "You need an identifier to generate a password" if not @identifier
    @passphrase = options[:passphrase]
    # If there's a passphrase, spin the key based on that, otherwise, use it as given
    key = get_key(options[:key])
    if @passphrase
      @key = spin(key.split(//), passphrase_spin).join
    else
      @key = key
    end
    @name = options[:name]
    @length = options[:length] || 8
  end

  def name_spin; @name.sha.nth_i(4) * @name.sha.nth_i(2) if @name; end
  def passphrase_spin; @passphrase.sha.nth_i(4) * @passphrase.sha.nth_i(2) if @passphrase; end
  
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

  def hashify str
    Hasher.new(str).hash
  end

  def generate
    # Generate an index based on the key. 
    # TODO: Weakness? This will be the same for all passwords with this key
    index = @key.sha.nth_i(4) + @key.sha.nth_i(2)
    hash = spin hashify(@identifier + @key).split(//), get_name_spin
    hash.join[index...(index + @length)]
  end
 
end

if __FILE__ == $0
  passfish = Passfish.new "mettadore", :key => 'abc123', :name => "test", :length => 20
  p passfish.generate
end
