require_relative '../spec_helper'

describe User do

  before do
    @user = FactoryGirl.build(:user)
  end

  subject { @user }

  it { should respond_to(:id)}
  it { should respond_to(:name)}
  it { should respond_to(:surname)}
  it { should respond_to(:email)}
  it { should respond_to(:type)}
  it { should respond_to(:full_name)}
  it { should respond_to(:password_hash)}
  it { should respond_to(:user_since)}
  it { should respond_to(:password_salt)}
  it { should respond_to(:password_confirmation)}
  it { should respond_to(:password)}

  it { should be_valid }
  
  describe "when password is empty" do
      before { @user.password = " " }
      it { should_not be_valid }
      end

  describe "when password is too short" do
      before { @user.password = "a"*5 }
      it { should_not be_valid }
      end

  describe "when password is too long" do
      before { @user.password = "a"*33 }
      it { should_not be_valid }
      end

  describe "when name is not present" do
      before { @user.name = " " }
      it { should_not be_valid }
    end
  
  describe "when name is too long" do
      before { @user.name = "a"*129 }
      it { should_not be_valid }
    end
  
  describe "when name is not non alphanumeric characters" do
      before { @user.name = "1234567890!\"" }
      it { should_not be_valid }
    end

  describe "when surname is got non alphanumeric characters" do
      before { @user.surname = "1234567890!\"" }
      it { should_not be_valid }
    end
  
  describe "when surname is too long" do
      before { @user.surname = "a"*129 }
      it { should_not be_valid }
    end

  describe "when surname is not present" do
      before { @user.surname = " " }
      it { should_not be_valid }
    end
  
  describe "when email is not present" do
      before { @user.email = " " }
      it { should_not be_valid }
    end

  describe "when email is not valid no @" do
      before { @user.email = "aa.de" }
      it { should_not be_valid }
    end

  describe "when email is not valid @ but no local" do
      before { @user.email = "@aa.de" }
      it { should_not be_valid }
    end

 describe "when email is not valid @ but no TLD" do
      before { @user.email = "a@" }
      it { should_not be_valid }
    end

 describe "when email is not valid @ in local" do
      before { @user.email = "@a@aa.de" }
      it { should_not be_valid }
    end

 describe "when email is not valid , instead of ." do
      before { @user.email = "a@aa,de" }
      it { should_not be_valid }
    end

  describe "check full name" do
    it "should be firstname, lastname" do
      expect(@user.full_name == "#{@user.name}, #{@user.surname}")
    end
  end

  describe "db saving and deleting" do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
      @user.save
    end

    after do
      begin
        @user.delete
      rescue
      end
    end
    
    it "should exist in databse" do
      checkUser = User.find_by_id(@user.id)
      expect(checkUser == @user)
    end

    it "should be completely removed from the db" do
      expect(@user.delete)
      expect{User.retrieve(@user.id)}.to raise_error
      expect{User.retrieve("email::#{@user.email.downcase}")}.to raise_error
    end
  end
end
