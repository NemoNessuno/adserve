require_relative '../spec_helper'
#TODO: more testcases. also negative ones
describe "Create a Campaign" do
 
  def logIn
    visit log_in_path
    fill_in "_sessions_email", with: SpecConstants::TEST_ADVERTISER_EMAIL
    fill_in "_sessions_password", with: SpecConstants::TEST_ADVERTISER_PASSWORD
    click_button "Log In"
  end

  def fillBaseData 
    page.find("#add_campaign_extender").click
    fill_in "campaign_name",          with: SpecConstants::TEST_CAMPAIGN_NAME
    fill_in "campaign_target_url",    with: SpecConstants::TEST_CAMPAIGN_TARGET_URL
    fill_in "campaign_budget",        with: SpecConstants::TEST_CAMPAIGN_BUDGET
    fill_in "campaign_cp_view",       with: SpecConstants::TEST_CAMPAIGN_CP_VIEW
    fill_in "campaign_cp_click",      with: SpecConstants::TEST_CAMPAIGN_CP_CLICK
    fill_in "campaign_cp_conversion", with: SpecConstants::TEST_CAMPAIGN_CP_CONVERSION
    pickDate
    select("Yearly", :from => "Budget type")
    select("DirectDebit", :from => "Billing type")
  end
  
  def clickAddCampaign
      page.find_link("Campaigns").click
  end
  
  def pickDate
    page.find("#campaign_expiration_date").click
    page.find("td", :text => "Today").click
  end

  def validateTable
    page.find("#show_campaigns_extender").click
    expect(page).to have_selector("td", :text => SpecConstants::TEST_CAMPAIGN_NAME)
    expect(page).to have_selector("td", :text => "0")
    expect(page).to have_selector("td", :text => Date.today.to_s)
  end

  def validateInstance
      advertiser = Advertiser.retrieve(@advertiser.id)
      actual = Campaign.retrieve(advertiser.campaign[0].id)
      actual.name.should eq(SpecConstants::TEST_CAMPAIGN_NAME)
      actual.budget.should eq(SpecConstants::TEST_CAMPAIGN_BUDGET)
      actual.cp_view.should eq(SpecConstants::TEST_CAMPAIGN_CP_VIEW)
      actual.cp_click.should eq(SpecConstants::TEST_CAMPAIGN_CP_CLICK)
      actual.cp_conversion.should eq(SpecConstants::TEST_CAMPAIGN_CP_CONVERSION)

      return actual
  end

  subject {page}
  
  let(:save) {"Save Campaign"}

  describe "without valid information" do
    before(:all) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      @advertiser = FactoryGirl.create(:advertiser)
    end
  
    before(:each) do
      logIn
    end

    it "should not create a campaign without basic data" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "can't be blank")
    end

     it "should not create a campaign with only a name" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fill_in "campaign_name", with: SpecConstants::TEST_CAMPAIGN_NAME
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "must be a valid datetime")
    end
 
     it "should not create a campaign without a name" do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fill_in "campaign_expiration_date", with: SpecConstants::TEST_CAMPAIGN_EXPIRATION_DATE
      expect{click_button save}.not_to change{page.current_path}
      expect(page).to have_selector(".error", :text => "can't be blank")
    end
  end
  
  describe "when saving" do
    before(:each) do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
            
      @advertiser = FactoryGirl.create(:advertiser)
      @ad = FactoryGirl.build(:ad)
      @advertiser.ad << @ad
      @ad.advertiser = @advertiser
      @ad.save

      logIn
    end

    it "should save a campaign when given basic information",:js => true do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fillBaseData
      expect{click_button save}.not_to change{page.current_path}

      validateTable
   end

    it "should save a campaign with categories when categories are added",:js => true do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fillBaseData
      page.first(".treegrid-expander").click
      check "Soccer"
      page.find('#Soccer').should be_checked
      expect{click_button save}.not_to change{page.current_path}
      
      actual = validateInstance
      actual.categories.should eq("Soccer")
      
      validateTable
    end
    
    it "should save a campaign with an ad when an ad is added",:js => true do
      expect{clickAddCampaign}.to change{page.current_path}.from(advertisers_home_path).to(advertisers_campaigns_path)
      fillBaseData
      page.first(".treegrid-expander").click

      check "Soccer"
      page.find('#Soccer').should be_checked

      check "ad_#{@ad.id}"
      
      expect{click_button save}.not_to change{page.current_path}
      
      actual = validateInstance
      actual.categories.should eq("Soccer")
      
      actual.ad[0].shallow_eq(@ad).should be_true
      
      validateTable
    end
  end
 
end
