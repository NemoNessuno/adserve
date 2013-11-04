require_relative '../spec_helper'
#TODO: more testcases. also negative ones
describe "Create an Ad" do
 
  def logIn
    visit log_in_path
    fill_in "_sessions_email",    with: SpecConstants::TEST_ADVERTISER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_ADVERTISER_PASSWORD
    click_button "Log In"
  end

  def fillBaseData 
    page.find("#add_ad_extender").click
    fill_in "ad_width",   with: SpecConstants::TEST_RECTANGLE_WIDTH
    fill_in "ad_height",  with: SpecConstants::TEST_RECTANGLE_HEIGHT
    fill_in "ad_content", with: SpecConstants::TEST_AD_1_CONTENT
  end
  
  def clickAddCampaign
      page.find_link("Campaigns").click
  end
  
  def validateTable
    page.find("#show_ads_extender").click
    expect(page).to have_selector("td", :text => SpecConstants::TEST_AD_1_CONTENT)
    expect(page).to have_selector("td", :text => "0")
  end

  def validateInstance
      advertiser = Advertiser.retrieve(@advertiser.id)
      actual = Ad.retrieve(advertiser.ad[0].id)
      actual.content.should eq(SpecConstants::TEST_AD_1_CONTENT)
      actual.size.should eq(SpecConstants::TEST_RECTANGLE_STRING)
      actual.clicksCount.should eq(0)
      actual.viewsCount.should eq(0)
      actual.conversionsCount.should eq(0)

      return actual
  end

  subject {page}
  
  let(:save) {"Save Ad"}

  describe "without valid information" do
    before(:all) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      FactoryGirl.create(:advertiser)
    end
  
    before(:each) do
      logIn
    end

    it "should not create a ad without basic data" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "width and height must be greater than 0")
    end

     it "should not create a ad with only content and width" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fill_in "ad_width", with: SpecConstants::TEST_RECTANGLE_WIDTH
      fill_in "ad_content", with: SpecConstants::TEST_AD_1_CONTENT
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "width and height must be greater than 0")
    end
 
     it "should not create a ad with only content and height" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fill_in "ad_height", with: SpecConstants::TEST_RECTANGLE_HEIGHT
      fill_in "ad_content", with: SpecConstants::TEST_AD_1_CONTENT
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "width and height must be greater than 0")
    end
 
     it "should not create a ad without content" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fill_in "ad_height", with: SpecConstants::TEST_RECTANGLE_HEIGHT
      fill_in "ad_width", with: SpecConstants::TEST_RECTANGLE_WIDTH
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "can't be blank")
    end
  end
  
  describe "when saving" do
    before(:each) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
            
      @advertiser = FactoryGirl.create(:advertiser)

      logIn
    end

    it "should save a campaign when given basic information",:js => true do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fillBaseData
      expect{click_button save}.not_to change{page.current_path}

      validateTable
      validateInstance
   end

  end
 
end
