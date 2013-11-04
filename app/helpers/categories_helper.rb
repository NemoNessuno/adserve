require 'yaml'
require 'couchbase'

module CategoriesHelper

  def readCategories
    YAML.load_file("#{File.expand_path("../../",__FILE__)}/assets/categories.yml")
  end

  def checkAndSave(override=false, bucket="adserve")
    @c ||= Couchbase.connect("http://localhost:8091/pools/default/buckets/#{bucket}")
    
    begin
      return unless override || @c.get("categories").nil? 
    rescue
      #do nothing
    end
    
    begin
      @c.set("categories", readCategories)
    rescue
      @c.replace("categories", readCategories)
    end
  end

  def getCategories(bucket="adserve")
    checkAndSave(false, bucket)

    @c.get("categories")
  end
end
