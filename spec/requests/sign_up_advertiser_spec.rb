require_relative '../spec_helper'

describe "Sign Up Advertiser" do
  
  def fillForm 
    fill_in "advertiser_email", with: SpecConstants::TEST_ADVERTISER_EMAIL
    fill_in "advertiser_name", with: SpecConstants::TEST_ADVERTISER_NAME
    fill_in "advertiser_surname", with: SpecConstants::TEST_ADVERTISER_SURNAME
    fill_in "advertiser_password", with: SpecConstants::TEST_ADVERTISER_PASSWORD
    fill_in "advertiser_password_confirmation", with: SpecConstants::TEST_ADVERTISER_PASSWORD
  end

  subject {page}

   let(:submit) {"Sign Up"}

   describe "without valid information" do
     before do
       @couchbaseserver = TestCouchbaseServer.new
       @couchbaseserver.start
 
       visit signup_advertiser_path 
     end
     it "should not create a user" do
       expect{Advertiser.retrieve(1)}.to raise_error
       expect{Advertiser.retrieve("email::#{SpecConstants::TEST_ADVERTISER_EMAIL}")}.to raise_error
     end
   end

   describe "after adding valid information" do
     before do
       @couchbaseserver = TestCouchbaseServer.new
       @couchbaseserver.start
       visit signup_advertiser_path
       fillForm
     end
     it "should create a user" do
       click_button submit
       actual = Advertiser.authenticate(SpecConstants::TEST_ADVERTISER_EMAIL, SpecConstants::TEST_ADVERTISER_PASSWORD)
       expect(actual.email).to eq(SpecConstants::TEST_ADVERTISER_EMAIL)
       expect(actual.name).to eq(SpecConstants::TEST_ADVERTISER_NAME)
       expect(actual.surname).to eq(SpecConstants::TEST_ADVERTISER_SURNAME)
     end
   end

   describe "before adding valid information" do
     before  do 
       @couchbaseserver = TestCouchbaseServer.new
       @couchbaseserver.start
       visit signup_advertiser_path
     end
     it "should not create a user but after adding the info it should" do
       expect{Advertiser.retrieve(1)}.to raise_error
       expect{Advertiser.retrieve("email::#{SpecConstants::TEST_ADVERTISER_EMAIL}")}.to raise_error
       fillForm
       click_button submit
       actual = Advertiser.authenticate(SpecConstants::TEST_ADVERTISER_EMAIL, SpecConstants::TEST_ADVERTISER_PASSWORD)
       expect(actual.email).to eq(SpecConstants::TEST_ADVERTISER_EMAIL)
       expect(actual.name).to eq(SpecConstants::TEST_ADVERTISER_NAME)
       expect(actual.surname).to eq(SpecConstants::TEST_ADVERTISER_SURNAME)
     end
   end

end
