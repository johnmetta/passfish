require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hasher do
  
  describe "basic methods" do
    describe "base64_hash" do
      it "Should generate a base64 encoded SHA hash from the supplied string"
      it "Should circularly shift the chars table based on the base64 hash"
    end
    
    it "should create a dictionary of letter to punctuation conversions"
    describe "is_numeric?" do
      before do
        @hasher = Hasher.new "test"
      end
      it "should return true for an integer string" do
          @hasher.is_numeric?("3").should be_true
      end
      it "should return false for a non-numeric string" do
          @hasher.is_numeric?("/").should be_false
          @hasher.is_numeric?("p").should be_false
      end
    end
    it "should create a noisy hash of 87 characters"
  end
  
  describe "Backward compatibility" do
    
    it "should return a known hash for a known string"
    
  end
end