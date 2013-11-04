require 'couchbase/model'

class AdServeModel < Couchbase::Model
  
  validate :validate_attributes
  before_save :save_associations
  
  attr_accessor :saving
  
  def shallow_eq(other_object)
    self.class == other_object.class && attributes == other_object.attributes
  end

  def ==(other_object)
    return false if self.class != other_object.class
    
    return false unless attributes == other_object.attributes
    
    #Compare all belongsTo
    self.class.belongsTo.each do |attribute|
      if send("#{attribute}") != other_object.send("#{attribute}")
        p "belongs_to atribute: #{attribute}: #{send("#{attribute}")} does not equal other_object attribute: #{other_object.send("#{attribute}")}"
        Rails.logger.debug "belongs_to atribute: #{attribute}: #{send("#{attribute}")} does not equal other_object attribute: #{other_object.send("#{attribute}")}"
        return false
      end
    end
    self.class.hasMany.each do |attribute|
      if send("#{attribute}") != other_object.send("#{attribute}")
        p "has_many atribute: #{attribute}: #{send("#{attribute}")} does not equal other_object attribute: #{other_object.send("#{attribute}")}"
        Rails.logger.debug "has_many atribute: #{attribute}: #{send("#{attribute}")} does not equal other_object attribute: #{other_object.send("#{attribute}")}"
        return false
      end
    end

    return true
  end

  def self.gatherBelongsToModels
    if (self == AdServeModel)
      []
    else
      belongsToAttributes.dup.concat adserveAncestor.gatherBelongsToModels
    end
  end

  def self.gatherHasManyModels
    if (self == AdServeModel)
      []
    else
      hasManyAttributes.dup.concat adserveAncestor.gatherHasManyModels
    end
  end

  def self.belongsTo
    @belongsToClasses ||= gatherBelongsToModels
  end

  def self.hasMany
    @hasManyClasses ||= gatherHasManyModels
  end

  def belongsToAttributeName(attrName)
    return self.class.belongs_to_string.concat(attrName.to_s).to_sym
  end

  def hasManyAttributeName(attrName)
    return self.class.has_many_string.concat(attrName.to_s).to_sym
  end
  
  # Returns the first ancestor that is also a AdServeModel ancestor. 
  def self.adserveAncestor
    ancestors[1..-1].each do |ancestor|
      return ancestor if ancestor.ancestors.include?(AdServeModel)
    end
  end
  
  def self.retrieve(id)
    data = find(id)
    data.fillAttributes(Hash[id,data])
    return data
  end

  def fillAttributes(alreadyLoaded)
    #First fill the belongsToAttributes
    fillBelongsToAttributes(alreadyLoaded)

    #Then fill the hasManyAttributes
    fillHasManyAttributes(alreadyLoaded)
    return
  end

  def fillBelongsToAttributes(alreadyLoaded)
    self.class.belongsTo.each do |attribute|
      id = send("#{self.class.belongs_to_string.concat(attribute.to_s).to_sym}")
      ownAttribute = send("#{attribute}")
      if (ownAttribute.nil?)
        foundData = alreadyLoaded[id]
        if(foundData.nil?)
          foundData = attribute.to_s.camelize.constantize.find(id)
          alreadyLoaded[id] = foundData
          foundData.fillAttributes(alreadyLoaded)
        end
        send("#{attribute}=", foundData)
      end
    end
  end

  def fillHasManyAttributes(alreadyLoaded)
    self.class.hasMany.each do |attribute|
      list = send("#{attribute}")
      send("#{self.class.has_many_string.concat(attribute.to_s).to_s}").each do |id|
        ownAttribute = list.find{ |obj| obj.id == id} 
        if (ownAttribute.nil?)
          foundData = alreadyLoaded[id]
          if (foundData.nil?)
            foundData = attribute.to_s.camelize.constantize.find(id)
            alreadyLoaded[id] = foundData
            foundData.fillAttributes(alreadyLoaded)
          end
          list << foundData
        end
      end
    end
  end

  def initialize(*args)
    super(*args)
    @saving  = false
    self.class.hasMany.each do |attr_name|
      instance_variable_set( "@#{attr_name.to_s}", Array.new)   
    end
  end
  
  def createID
    return Couchbase::Model::UUID.generator.next(1, :random)
  end

  def save_associations
    @private_errors = Hash.new
    @saving = true
    @id ||= createID
    #First we gather the objects that we belong to
      self.class.belongsTo.each do |attribute|
        newClass = send("#{attribute}")
        #If any of the classes we belong to is nil we can not be valid!
        if (newClass.nil?)
          @private_errors[attribute.to_sym] = "#{attribute} is nil and we belong to it! It must not be nil!"
          return
        end

        if (!newClass.saving)
          newClass.save
        end
        send("#{belongsToAttributeName(attribute)}=", newClass.id)
      end      

    #Then we gather the objects that we have many of
      self.class.hasMany.each do |attribute|
        idList = []
        send("#{attribute}").each do |model|
          if (!model.saving)
            if (model.valid?)
              model.save
            else
              @private_errors[attribute.to_sym] = " The object #{model} of class #{attribute} is invalid"
            end
          end
          idList << model.id
        end
        send("#{hasManyAttributeName(attribute)}=", idList)
      end
    @saving = false
    return
  end

  def validate_attributes
    #First we copy the private errors
    @private_errors ||= Hash.new
    @private_errors.each do |key, value|
      errors.add(key, value)
    end

    #we validate the objects we belong_to
    self.class.belongsTo.each do |attribute|
      retrievedClass = send("#{attribute}")
      unless !retrievedClass.nil? and retrievedClass.is_a? attribute.to_s.camelize.constantize
        errors.add(attribute.to_sym, "#{self.class} belongs_to an invalid #{attribute} It should be of class #{attribute.to_s} but is #{retrievedClass.class.name}")
      end
    end 

    #Then we validate the objects we have many of
    self.class.hasMany.each do |attribute|
      send("#{attribute}").each do |model|
        errors.add(attribute.to_sym, "#{self.class} has an invalid #{attribute}")unless model.is_a? attribute.to_s.camelize.constantize
      end
    end
  end
  
  private :save_associations, :validate_attributes

end
