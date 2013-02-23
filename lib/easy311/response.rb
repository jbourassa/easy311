module Easy311

  class Response
    include ActiveAttr::Model

    attribute :service_request_id
    attribute :token
    attribute :service_notice
    attribute :account_id
    attribute :error_message

    def valid?
      error_message.nil?
    end

    def invalid?
      !valid?
    end

  end

end
