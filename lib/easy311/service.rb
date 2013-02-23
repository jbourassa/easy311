module Easy311

  class Service
    include ActiveAttr::Model

    attribute :name
    attribute :code
    attribute :group
    attribute :description
    attribute :metadata
    attribute :type
    attribute :attrs, :default => {}

    def service_name=(value)
      self.name = value
    end

    def service_code=(value)
      self.code = value
    end

    def attrs=(values)
      if values.is_a?(Array)
        super Hash[values.map { |value| [value.code, value] }]
      elsif values.is_a?(Hash)
        super values
      else
        raise TypeError
      end
    end

    def ordered_attrs
      Hash[attrs.sort_by { |k, v| v.code }]
    end

    def to_param
      code
    end
  end

end
