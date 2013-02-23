module Easy311

  class Attribute
    include ActiveAttr::Model

    attribute :code
    attribute :datatype
    attribute :description
    attribute :datatype_description
    attribute :order
    attribute :required
    attribute :values
    attribute :variable

  end

end
