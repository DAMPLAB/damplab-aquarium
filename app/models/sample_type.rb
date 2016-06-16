class SampleType < ActiveRecord::Base

  include FieldTyper

  after_destroy :destroy_fields

  attr_accessible :description, :field1name, :field1type, :field2name, :field2type, :field3name, 
                                :field3type, :field4name, :field4type, :field5name, :field5type, 
                                :field6name, :field6type, :field7name, :field7type, :field8name, :field8type,  
                                :name, :datatype

  has_many :samples
  has_many :object_types

  validates :name, presence: true
  validates :description, presence: true

  validate :proper_choices # deprecated

  #############################################################################################
  # Mostly deprecated stuff below

  def fieldname i # deprecated
    n = "field#{i}name".to_sym
    self[n]
  end

  def fieldtype i # deprecated
    t = "field#{i}type".to_sym
    if self[t]
      self[t].split "|"
    else
      []
    end
  end

  def field_index name # deprecated

    i = 1
    while i<=8 && self["field#{i}name".to_sym] != name
      i += 1
    end

    if i<= 8
      i
    else
      nil
    end

  end

  def proper_choices # deprecated

    unary =  ['not used','string','number','url']

    (1..8).each do |i|
      t = self.fieldtype i
      if t.length > 1
        unary.each do |u|
          if t.include? u
            errors.add(:improper_or,"Multiple types can only consist of links to other samples.")
            return
          end
        end
      end
    end

  end

  def export
    attributes
  end

  ####################################################################################################
  # UNUSED WORKFLOW STUFF FROM HERE TO EOF: OKAY TO EVENTUALLY DELETE   

  def datatype_hash
    begin
      JSON.parse(self.datatype,symbolize_names: true)
    rescue Exception => e
      { type: "number", error: "Parse error in JSON. Default data type used." }
    end
  end

  def self.folders 

    { id: -1, 
      name: "All Samples", 
      children: SampleType.all.collect { |st| {
         id: -1, 
         name: st.name.pluralize, 
         sample_type_id: st.id,
         locked: true
        } 
      },
      locked: true
    }

  end

end
