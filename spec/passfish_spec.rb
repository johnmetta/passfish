require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Passfish do

  it "should fail when not given an identifier in the constructor" do
    pending do
      Passfish.new.should raise_error(ArgumentError)
    end
  end
  
  describe "basic methods" do
    describe "is_numeric?" do
      before do
        @passfish = Passfish.new "test", :key => 'abc123'
      end
      it "should return true for an integer string" do
          @passfish.is_numeric?("3").should be_true
      end
      it "should return false for a non-numeric string" do
          @passfish.is_numeric?("/").should be_false
          @passfish.is_numeric?("p").should be_false
      end
    end
    
    describe "get_key" do
      it "should return a the correct key given the --key or -k commandline option" do
        passfish = Passfish.new "test", :key => 'abc123'
        passfish.key.should == 'abc123'
      end
      it "should fail to a default keypath if not given the -k option"
      it "should generate a default keyfile if no default keyfile or -k options"
      it "should read a previously generated keyfile correctly"
    end
    
    describe "combine_params" do
      it "Should combine with only a key" do
        passfish = Passfish.new "test", :key => 'abc123'
        passfish.combine_params.should == "testabc123"
      end
      it "should combine with a key and a name" do
        passfish = Passfish.new "test", :key => 'abc123', :name => 'a test'
        passfish.combine_params.should == "testabc123a test"
      end
      it "should combine with a key and a passphrase" do
        passfish = Passfish.new "test", :key => 'abc123', :passphrase => 'a contrived example'
        passfish.combine_params.should == "testabc123a contrived example"
      end
      it "should combine with a key, passphrase and name" do      
        passfish = Passfish.new "test", :key => 'abc123', :name => 'a test', :passphrase => 'a contrived example'
        passfish.combine_params.should == "testabc123a testa contrived example"
      end
    end

    describe "make_hash_string" do
      it "Should make a valid hash with only a key" do
        passfish = Passfish.new "test", :key => 'abc123'
        passfish.make_hash_string.should == (Digest::SHA2.new << "testabc123").to_s
      end
      it "should make a valid hash with a key and a name" do
        passfish = Passfish.new "test", :key => 'abc123', :name => 'a test'
        passfish.make_hash_string.should == (Digest::SHA2.new << "testabc123a test").to_s
      end
      it "should make a valid hash with a key and a passphrase" do
        passfish = Passfish.new "test", :key => 'abc123', :passphrase => 'a contrived example'
        passfish.make_hash_string.should == (Digest::SHA2.new << "testabc123a contrived example").to_s
      end
      it "should make a valid hash with a key, passphrase and name" do      
        passfish = Passfish.new "test", :key => 'abc123', :name => 'a test', :passphrase => 'a contrived example'
        passfish.make_hash_string.should == (Digest::SHA2.new << "testabc123a testa contrived example").to_s
      end
    end
    
    describe "make_rsa_key" do
      it "should make a valid RSA key"
    end
    
    describe "generate_and_read_keyfile" do
      it "should generate a keyfile and read it back"
    end
  end
  
  describe "given a valid private key" do
    
    describe "given a valid identifier ('test')" do
      before do
        key = 'this damn contrived example'
        @passfish_A = Passfish.new "test", :key => key
        @passfish_B = Passfish.new "test", :key => key
      end

      it "should generate a valid password repeatably" do
        @passfish_A.generate.should == @passfish_A.generate
      end
      
      it "should generate the same valid password in different instances" do
        @passfish_B.generate.should == @passfish_A.generate
      end
      
      it "should generate a valid password with a specified length" do
        @passfish_A.length = 13
        @passfish_A.generate.length.should == 13
      end
      
      it "should default to 8 character length" do
        @passfish_B.generate.length.should == 8
      end
      
      it "should not generate the same password with a different identifier" do
        passa = Passfish.new "atest", :key => 'this damn contrived example'
        passb = Passfish.new "test1", :key => 'this damn contrived example'
        passa.generate.should_not == @passfish_B.generate
        passb.generate.should_not == @passfish_B.generate
      end
      
      describe "given a passphrase" do
        before do
          key = 'this key'
          phrase = 'this contrived phrase'
          @passfish_X = Passfish.new "test", :key => key, :passphrase => phrase
          @passfish_Y = Passfish.new "test", :key => key, :passphrase => phrase
        end

        it "should generate a valid password repeatably in different instances" do
          @passfish_Y.generate.should == @passfish_X.generate
        end
        
        it "should generate a valid password with a specified length repeatably" do
          @passfish_X.length = 17
          @passfish_Y.length = 17
          @passfish_X.generate.should == @passfish_Y.generate
          @passfish_X.generate.length.should == 17
        end
        
        it "should generate an incorrect password with an invalid passphrase" do
          passfish = Passfish.new "test", :key => 'this key', :passphrase => 'that contrived phrase'
          passfish.generate.should_not == @passfish_X.generate
        end
        
        it "should generate an incorrect password if given a name" do
          passfisha = Passfish.new "test", :key => "this key", :passphrase => 'this contrived phrase', :name => 'somename'
          passfishb = Passfish.new "test", :key => "this key", :passphrase => 'this contrived phrase'
          passfisha.generate.should_not == @passfish_X.generate
          passfishb.generate.should == @passfish_X.generate
        end
      end

      describe "given a name" do
        before do
          key = 'this key'
          name = 'somename'
          @passfish_I = Passfish.new "test", :key => key, :name => name
          @passfish_J = Passfish.new "test", :key => key, :name => name
        end
        it "should generate a valid password repeatably" do
          @passfish_I.generate.should == @passfish_J.generate          
        end
        
        it "should generate a valid password with a specificed length repeatably" do
          @passfish_I.length = 11
          @passfish_J.length = 11
          @passfish_I.generate.should == @passfish_J.generate
          @passfish_I.generate.length.should == 11          
        end
        
        it "should generate an incorrect password with an invalid name" do
          passfish = Passfish.new "test", :key => 'this key', :name => 'aname'
          passfish.generate.should_not == @passfish_I.generate
        end
        
        it "should generate an incorrect password given a passphrase" do
          passfish = Passfish.new "test", :key => 'this key', :name => 'somename', :passphrase => 'Something as a passphrase'
          passfish.generate.should_not == @passfish_J.generate
        end
      end
    end
    describe "given an invalid identifier" do
      it "should generate an incorrect password" do
        pending
      end
      
      it "should generate an incorrect password given a valid name" do
        pending
      end
      
      it "should generate an incorrect password given a valid passphrase" do
        pending
      end
    end
  end
  describe "given an invalid key" do
  end
end
