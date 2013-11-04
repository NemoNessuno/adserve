require_relative '../spec_helper'

describe "Sign Up Publisher" do
  
  def fillForm 
    fill_in "publisher_email", with: SpecConstants::TEST_PUBLISHER_EMAIL
    fill_in "publisher_name", with: SpecConstants::TEST_PUBLISHER_NAME
    fill_in "publisher_surname", with: SpecConstants::TEST_PUBLISHER_SURNAME
    fill_in "publisher_password", with: SpecConstants::TEST_PUBLISHER_PASSWORD
    fill_in "publisher_password_confirmation", with: SpecConstants::TEST_PUBLISHER_PASSWORD
  end

  subject {page}

   let(:submit) {"Sign Up"}

   describe "without valid information" do
     before { visit signup_publisher_path }
     it "should not create a user" do
      expect{Publisher.retrieve(1)}.to raise_error
      expect{Publisher.retrieve("email::#{SpecConstants::TEST_PUBLISHER_EMAIL}")}.to raise_error
     end
   end

   describe "after adding valid information" do
     before do
       @couchbaseserver = TestCouchbaseServer.new
       @couchbaseserver.start
       visit signup_publisher_path
       fillForm
     end
     it "should create a user" do
       click_button submit
       actual = Publisher.authenticate(SpecConstants::TEST_PUBLISHER_EMAIL, SpecConstants::TEST_PUBLISHER_PASSWORD)
       expect(actual.email).to eq(SpecConstants::TEST_PUBLISHER_EMAIL)
       expect(actual.name).to eq(SpecConstants::TEST_PUBLISHER_NAME)
       expect(actual.surname).to eq(SpecConstants::TEST_PUBLISHER_SURNAME)
     end
   end

   describe "before adding valid information" do
     before  do 
       @couchbaseserver = TestCouchbaseServer.new
       @couchbaseserver.start
       visit signup_publisher_path
     end
     it "should not create a user but after adding the info it should" do
       expect{Publisher.retrieve(1)}.to raise_error
       expect{Publisher.retrieve("email::#{SpecConstants::TEST_PUBLISHER_EMAIL}")}.to raise_error
       fillForm
       click_button submit
       actual = Publisher.authenticate(SpecConstants::TEST_PUBLISHER_EMAIL, SpecConstants::TEST_PUBLISHER_PASSWORD)
       expect(actual.email).to eq(SpecConstants::TEST_PUBLISHER_EMAIL)
       expect(actual.name).to eq(SpecConstants::TEST_PUBLISHER_NAME)
       expect(actual.surname).to eq(SpecConstants::TEST_PUBLISHER_SURNAME)
     end
   end

end
