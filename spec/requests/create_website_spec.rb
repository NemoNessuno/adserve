require_relative '../spec_helper'
#TODO: more testcases. also negative ones
describe "Create a Website" do
 
  def logIn
    visit log_in_path
    fill_in "_sessions_email", with: SpecConstants::TEST_PUBLISHER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_PUBLISHER_PASSWORD
    click_button "Log In"
  end

  def fillBaseData 
    fill_in "website_name", with: SpecConstants::TEST_WEBSITE_NAME
    fill_in "website_base_url", with: SpecConstants::TEST_WEBSITE_BASE_URL
    fill_in "website_description", with: SpecConstants::TEST_WEBSITE_DESCRIPTION
  end
  
  def addZone 
    fill_in "zone_width", with: SpecConstants::TEST_RECTANGLE_WIDTH
    fill_in "zone_height", with: SpecConstants::TEST_RECTANGLE_HEIGHT
    page.find('p',:text => "Add Zone").click
  end

  def clickAddWebsite
      page.find_link("Websites").click
  end

  subject {page}
  
  let(:add_zone) {"Add Zone"}
  let(:save) {"Save Website"}

  describe "without valid information" do
    before(:all) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      FactoryGirl.create(:publisher)
    end

    before(:each) do
      logIn
    end

    it "should not create a website without a name or description" do
      expect{clickAddWebsite}.to change{page.current_path}.from(publishers_home_path).to(publishers_websites_path)
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "can't be blank")
    end

     it "should not create a website without a description" do
      expect{clickAddWebsite}.to change{page.current_path}.from(publishers_home_path).to(publishers_websites_path)
      fill_in "website_name", with: SpecConstants::TEST_WEBSITE_NAME
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "can't be blank")
    end
 
     it "should not create a website without a name" do
      expect{clickAddWebsite}.to change{page.current_path}.from(publishers_home_path).to(publishers_websites_path)
      fill_in "website_description", with: SpecConstants::TEST_WEBSITE_DESCRIPTION
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "can't be blank")
    end
  end
  
  describe "when saving" do
    before(:each) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
            
      @publisher = FactoryGirl.create(:publisher)
      logIn
    end

    it "should save a website when given basic information" do
      expect{clickAddWebsite}.to change{page.current_path}.from(publishers_home_path).to(publishers_websites_path)
      fillBaseData
      expect{click_button save}.not_to change{page.current_path}
      page.find("#show_websites_extender").click
      expect(page).to have_selector("td", :text => SpecConstants::TEST_WEBSITE_NAME)
      expect(page).to have_selector("td", :text => SpecConstants::TEST_WEBSITE_DESCRIPTION)
    end

    it "should save a website with categories when categories are added",:js => true do
      expect{clickAddWebsite}.to change{page.current_path}.from(publishers_home_path).to(publishers_websites_path)
      page.find("#add_website_extender").click
      fillBaseData
      page.first(".treegrid-expander").click
      check "Soccer"
      page.find('#Soccer').should be_checked
      expect{click_button save}.not_to change{page.current_path}
      page.find("#show_websites_extender").click
      publisher = Publisher.retrieve(@publisher.id)
      actual = Website.retrieve(publisher.website[0].id)
      actual.name.should eq(SpecConstants::TEST_WEBSITE_NAME)
      actual.description.should eq(SpecConstants::TEST_WEBSITE_DESCRIPTION)
      actual.categories.should eq("Soccer")

      expect(page).to have_selector("td", :text => SpecConstants::TEST_WEBSITE_NAME)
      expect(page).to have_selector("td", :text => SpecConstants::TEST_WEBSITE_DESCRIPTION)

    end
    
    it "should save a website with zones when a zone is added",:js => true do
      expect{clickAddWebsite}.to change{page.current_path}.from(publishers_home_path).to(publishers_websites_path)
      page.find("#add_website_extender").click
      fillBaseData
      addZone
      page.first(".treegrid-expander").click
      check "Soccer"
      page.find('#Soccer').should be_checked
      expect{click_button save}.not_to change{page.current_path}
      page.find("#show_websites_extender").click
      publisher = Publisher.retrieve(@publisher.id)
      actual = Website.retrieve(publisher.website[0].id)
      actual.name.should eq(SpecConstants::TEST_WEBSITE_NAME)
      actual.description.should eq(SpecConstants::TEST_WEBSITE_DESCRIPTION)
      actual.categories.should eq("Soccer")
      actual.zone[0].size.should eq(SpecConstants::TEST_RECTANGLE_STRING)

      expect(page).to have_selector("td", :text => SpecConstants::TEST_WEBSITE_NAME)
      expect(page).to have_selector("td", :text => SpecConstants::TEST_WEBSITE_DESCRIPTION)

    end
  end
 
end
