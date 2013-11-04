module Associations
  module ClassMethods
  
    def create_method( name, &block )
      self.send( :define_method, name, &block )
    end

    def create_attr( name )
      create_method( "#{name}=".to_sym ) { |val| 
        instance_variable_set( "@" + name, val)
      }

      create_method( name.to_sym ) { 
        instance_variable_get( "@" + name ) 
      }
    end
    
    def belongs_to_string
      return "belongs_to"
    end

    def has_many_string
      return "has_many"
    end

    #Add the attributeName to the belongsToAttributes
    #and add a field in the list for the IDs
    def belongs_to(*attributes)
      attributes.each do |attr_name|
        belongsToAttributes << attr_name

        create_attr attr_name.to_s
        attribute belongs_to_string.concat(attr_name.to_s).to_sym
      end
    end

    #Add the attributeName to the hasManyAttributes
    #and add a field in the list for the IDs
    def has_many(*attributes)
      attributes.each do |attr_name|
        hasManyAttributes << attr_name

        attr_reader attr_name.to_sym
        attribute has_many_string.concat(attr_name.to_s).to_sym
      end
    end

    def belongsToAttributes
      @belongsToAttributes ||= []
    end

    def hasManyAttributes
      @hasManyAttributes ||= []
    end

  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end  
  end

end
# prepend the extension 
Couchbase::Model.send(:prepend, Associations)
