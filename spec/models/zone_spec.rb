require_relative '../spec_helper'
#TODO: Test width and height!
describe Zone do

  before do
    @zone = FactoryGirl.build(:zone)
    @website = FactoryGirl.build(:website)
    @zone.website = @website
  end

  subject { @zone }

  it { should respond_to :size }
  it { should respond_to :view }
  it { should respond_to :width }
  it { should respond_to :height }
  it { should respond_to :click }
  it { should respond_to :conversion }
  it { should respond_to :ad }
  it { should respond_to :website }

  it { should be_valid }

  describe "if website is nil" do
    before {@zone.website = nil}
    it {should_not be_valid}
  end
  
  describe "should have correct width" do
    it {expect(@zone.width).to eq SpecConstants::TEST_RECTANGLE_WIDTH}
  end

  describe "should have correct height" do
    it {expect(@zone.height).to eq SpecConstants::TEST_RECTANGLE_HEIGHT}
  end

end
