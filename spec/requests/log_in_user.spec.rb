require_relative '../spec_helper'

describe "Log in User" do

  def fillCorrectAdvertiser 
    fill_in "_sessions_email", with: SpecConstants::TEST_ADVERTISER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_ADVERTISER_PASSWORD
  end

  def fillCorrectPublisher 
    fill_in "_sessions_email", with: SpecConstants::TEST_PUBLISHER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_PUBLISHER_PASSWORD
  end
  
  def fillWrongAdvertiser 
    fill_in "_sessions_email", with: SpecConstants::TEST_ADVERTISER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_PUBLISHER_PASSWORD
  end

  def fillWrongPublisher 
    fill_in "_sessions_email", with: SpecConstants::TEST_PUBLISHER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_ADVERTISER_PASSWORD
  end


  subject {page}

  let(:submit) {"Log In"}

  describe "When user does not exists" do
    before(:all) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
    end

    before(:each) { visit log_in_path }

    it "should not log in when no credentials are given" do
      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end
    
    it "should not log in when correct credentials are given" do
      fillCorrectAdvertiser

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
      
      fillCorrectPublisher

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end

    it "should not log in when wrong credentials are given" do
      fillWrongAdvertiser

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
      
      fillWrongPublisher

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end

  end

  describe "When advertiser was added" do
    before(:all) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      FactoryGirl.create(:advertiser)
    end
    
    before(:each) { visit log_in_path }

    it "should not log in when no credentials are given" do
      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end
    
    it "should log in when correct credentials are given" do
      fillCorrectAdvertiser

      expect{click_button submit}.to change{page.current_path}.from(log_in_path).to(advertisers_home_path)
      #TODO: find correct text expect(page).to have_selector(".message", :text => "Invalid email or password")
   end

    it "should not log in when wrong credentials are given" do
      fillCorrectPublisher

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
      
      fillWrongAdvertiser

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
      
      fillWrongPublisher

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end
  end

  describe "When publisher was added" do
    before(:all)  do 
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      FactoryGirl.create(:publisher)
    end
    before(:each) { visit log_in_path }

    it "should not log in when no credentials are given" do
      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end
    
    it "should log in when correct credentials are given" do
      fillCorrectPublisher
      
      expect{click_button submit}.to change{page.current_path}.from(log_in_path).to(publishers_home_path)
      #TODO: find correct text expect(page).to have_selector(".message", :text => "Invalid email or password")
   end

    it "should not log in when wrong credentials are given" do
      fillCorrectAdvertiser
      
      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
      
      fillWrongAdvertiser

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
      
      fillWrongPublisher

      expect{click_button submit}.not_to change{page.current_path}
      expect(page).to have_selector(".message", :text => "Invalid email or password")
    end
  end
end
