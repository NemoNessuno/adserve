require_relative '../spec_helper'

SOME_ATTRIBUTE = "some_attribute"

#TODO: Test whether an object is updated everywhere when any class it is associated with is saved (This may be VERY expensive regarding computation time)
#TODO: Test inheritance of has_many, belongs_to attributes - some more!
#TODO: Test that an object can only be added once to an association

#This class actually tests the AdServeModel module.
#Refer to spec_constants.rb to see the class
#setup for this tests
describe AdServeModel do

  before do
    @testAdServeModel1   = TestAdServeModel1.new
    @testAdServeModel1.test_attribute=SOME_ATTRIBUTE
    @testAdServeModel2   = TestAdServeModel2.new
    @testAdServeModel3   = TestAdServeModel3.new
    @testAdServeModel2_2 = TestAdServeModel2.new
    @testAdServeModel3_3 = TestAdServeModel3.new
    @testAdServeModel4   = TestAdServeModel4.new
    @testAdServeModel5   = TestAdServeModel5.new
    @testAdServeModel5.test_attribute=SOME_ATTRIBUTE
    @testAdServeModel6   = TestAdServeModel6.new
    @testAdServeModel7   = TestAdServeModel7.new
    @testAdServeModel8   = TestAdServeModel8.new
    @testAdServeModel9   = TestAdServeModel9.new
    @testAdServeModel11  = TestAdServeModel11.new
    @testAdServeModel12  = TestAdServeModel12.new
    @testAdServeModel13  = TestAdServeModel13.new
  end

  describe "when an object belongs_to another object" do
    before { @testAdServeModel2.testAdServeModel1 = @testAdServeModel1 }
    it "should be possible to add objects of that other class and retrieve them" do
      @testAdServeModel2.testAdServeModel1.should be @testAdServeModel1 
    end
  end

  describe "when an class has_many associations to another class" do
    before { @testAdServeModel1.testAdServeModel2 << @testAdServeModel2 }
    it "should be possible to add objects of that other class and retrieve them" do
      @testAdServeModel1.testAdServeModel2[0].should be @testAdServeModel2
    end
  end

  describe "when an class has_many other class but no object has been added" do
    it "should be an empty list" do
      @testAdServeModel1.testAdServeModel2.length.should be 0
    end
  end

  describe "when an class has_many associations to another class" do
    before { 
      @testAdServeModel1.testAdServeModel2 << @testAdServeModel2 
      @testAdServeModel1.testAdServeModel2 << @testAdServeModel2_2 
    }
    it "should be possible to add more than one object of that other class and retrieve them" do
      @testAdServeModel1.testAdServeModel2[0].should be @testAdServeModel2
      @testAdServeModel1.testAdServeModel2[1].should be @testAdServeModel2_2
    end
  end

  describe "when a class has several belongs_to associations" do
    before do
      @testAdServeModel3.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel3.testAdServeModel2 = @testAdServeModel2
    end
    it "should be possible to add objects of those classes and retrieve them" do
      @testAdServeModel3.testAdServeModel1.should be @testAdServeModel1
      @testAdServeModel3.testAdServeModel2.should be @testAdServeModel2
    end
  end

  describe "when an object which belongs_to another class is saved" do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
      @testAdServeModel2.testAdServeModel1=@testAdServeModel1
      @testAdServeModel2.save
    end
    it "should be possible to add objects of that other class and retrieve them" do
      actual = TestAdServeModel2.retrieve(@testAdServeModel2.id)
      expect(actual.testAdServeModel1.id).to eq @testAdServeModel1.id
      expect(actual.testAdServeModel1.test_attribute).to eq @testAdServeModel1.test_attribute
    end
  end

  describe "when an object which has_many of another class is saved" do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
      @testAdServeModel1.testAdServeModel2 << @testAdServeModel2 
      @testAdServeModel1.testAdServeModel2 << @testAdServeModel2_2 
      @testAdServeModel1.testAdServeModel3 << @testAdServeModel3
      
      @testAdServeModel2.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel2_2.testAdServeModel1 = @testAdServeModel1
      
      @testAdServeModel3.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel3.testAdServeModel2 = @testAdServeModel2 
      @saved = @testAdServeModel1.save!
    end
    it "should be possible to add objects of that other class and retrieve them" do
      @testAdServeModel1.should be_valid
      @testAdServeModel2.should be_valid
      @testAdServeModel2_2.should be_valid
      @testAdServeModel3.should be_valid
      @saved.should be_true
      actual = TestAdServeModel1.retrieve(@testAdServeModel1.id)
      expect(actual.testAdServeModel2[0].id).to eq @testAdServeModel2.id
      expect(actual.testAdServeModel2[1].id).to eq @testAdServeModel2_2.id
      expect(actual.testAdServeModel3[0].id).to eq @testAdServeModel3.id
      expect(actual.test_attribute).to eq @testAdServeModel1.test_attribute
    end
  end

  describe "when complex associations are saved" do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start
      @testAdServeModel1.testAdServeModel2 << @testAdServeModel2 
      @testAdServeModel1.testAdServeModel2 << @testAdServeModel2_2 
      @testAdServeModel1.testAdServeModel3 << @testAdServeModel3
      @testAdServeModel1.testAdServeModel3 << @testAdServeModel3_3
      
      @testAdServeModel2.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel2_2.testAdServeModel1 = @testAdServeModel1
      
      @testAdServeModel3.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel3.testAdServeModel2 = @testAdServeModel2 
      
      @testAdServeModel3_3.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel3_3.testAdServeModel2 = @testAdServeModel2_2

      @saved = @testAdServeModel1.save!
    end
    it "should be possible to retrieve all saved objects" do
      @testAdServeModel1.should be_valid
      @testAdServeModel2.should be_valid
      @testAdServeModel2_2.should be_valid
      @testAdServeModel3.should be_valid
      @testAdServeModel3_3.should be_valid

      @saved.should be_true

      #TestAdServeModel1
      actual1 = TestAdServeModel1.retrieve(@testAdServeModel1.id)
      expect(actual1.testAdServeModel2[0].id).to eq @testAdServeModel2.id
      expect(actual1.testAdServeModel2[1].id).to eq @testAdServeModel2_2.id
      expect(actual1.testAdServeModel3[0].id).to eq @testAdServeModel3.id
      expect(actual1.testAdServeModel3[1].id).to eq @testAdServeModel3_3.id
      expect(actual1.test_attribute).to eq @testAdServeModel1.test_attribute

      #TestAdServeModel2
      actual2 = TestAdServeModel2.retrieve(@testAdServeModel2.id)
      expect(actual2.testAdServeModel1.id).to eq @testAdServeModel1.id
      expect(actual2.testAdServeModel1.test_attribute).to eq @testAdServeModel1.test_attribute

      #TestAdServeModel2_2
      actual2_2 = TestAdServeModel2.retrieve(@testAdServeModel2_2.id)
      expect(actual2_2.testAdServeModel1.id).to eq @testAdServeModel1.id
      #TestAdServeModel3
      actual3 = TestAdServeModel3.retrieve(@testAdServeModel3.id)
      expect(actual3.testAdServeModel1.id).to eq @testAdServeModel1.id
      expect(actual3.testAdServeModel2.id).to eq @testAdServeModel2.id
 
      #TestAdServeModel3_3
      actual3_3 = TestAdServeModel3.retrieve(@testAdServeModel3_3.id)
      expect(actual3_3.testAdServeModel1.id).to eq @testAdServeModel1.id
      expect(actual3_3.testAdServeModel2.id).to eq @testAdServeModel2_2.id
    end
  end

  describe "if one of the associated attributes is assigned an object of the wrong class" do
    before do 
      @testAdServeModel2.testAdServeModel1 = @testAdServeModel3
    end
    it "should not be valid" do
      @testAdServeModel2.should_not be_valid
    end
  end

  describe "if one of the associated models is not valid" do
    before do 
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      @testAdServeModel2.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel2.testAdServeModel5 << @testAdServeModel5
      @testAdServeModel5.test_attribute = nil
      @saved = @testAdServeModel2.save
    end
    it "should not be valid until we made sure the associated model is valid" do
      @saved.should_not be_true
      @testAdServeModel2.should_not be_valid
      @testAdServeModel5.should_not be_valid

      @testAdServeModel5.test_attribute = SOME_ATTRIBUTE   
      @saved = @testAdServeModel2.save

      @saved.should_not be_true
      @testAdServeModel2.should_not be_valid
      @testAdServeModel5.should_not be_valid

      @testAdServeModel5.testAdServeModel2 = @testAdServeModel2
      @saved = @testAdServeModel2.save

      @saved.should_not be_false
      @testAdServeModel2.should be_valid
      @testAdServeModel5.should be_valid
    end
  end

  describe "if one model inherits another" do
    before do
      @testAdServeModel7.testAdServeModel6 << @testAdServeModel6
      
      @testAdServeModel3.testAdServeModel1 = @testAdServeModel1
      @testAdServeModel3.testAdServeModel2 = @testAdServeModel2 
      @testAdServeModel8.testAdServeModel3 << @testAdServeModel3
    end

    it "should contain the same associations" do
      @testAdServeModel7.should_not be_valid

      @testAdServeModel7.testAdServeModel5 = @testAdServeModel5
      @testAdServeModel7.should be_valid
      expect(@testAdServeModel7.testAdServeModel6[0]).to eq(@testAdServeModel6)

      @testAdServeModel8.should_not be_valid
      
      @testAdServeModel8.testAdServeModel5 = @testAdServeModel5

      @testAdServeModel8.should be_valid
      expect(@testAdServeModel8.testAdServeModel3[0].testAdServeModel1).to eq(@testAdServeModel1)
      expect(@testAdServeModel8.testAdServeModel3[0].testAdServeModel2).to eq(@testAdServeModel2)
    end
  end

  describe "When there is a use-case like the Publisher-website-zone relationship and it is saved" do
    before do
      @couchbaseserver = TestCouchbaseServer.new
      @couchbaseserver.start

      @testAdServeModel9.testAdServeModel11 << @testAdServeModel11
      
      @testAdServeModel11.testAdServeModel9 =  @testAdServeModel9
      @testAdServeModel11.testAdServeModel12 << @testAdServeModel12

      @testAdServeModel12.testAdServeModel13 << @testAdServeModel13
      @testAdServeModel13.testAdServeModel12 =  @testAdServeModel12
    end

    it "all retrieved models should contain all associations" do
      @testAdServeModel9.save!
      
      actual9 = TestAdServeModel9.retrieve(@testAdServeModel9.id)
      actual11 = actual9.testAdServeModel11[0]
      expect(actual11.id).to eq(@testAdServeModel11.id)
      expect(actual11.testAdServeModel9.id).to eq(@testAdServeModel9.id)
      
      actual12 = actual11.testAdServeModel12[0]
      expect(actual12.id).to eq(@testAdServeModel12.id)

      actual13 = actual12.testAdServeModel13[0]
      expect(actual13.id).to eq(@testAdServeModel13.id)
      expect(actual12.id).to eq(@testAdServeModel13.testAdServeModel12.id)
    end
  end

end
