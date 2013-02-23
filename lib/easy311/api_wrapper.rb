require 'rest-client'
require 'json'
require 'easy311/service'
require 'easy311/attribute'
require 'logger'

module Easy311

  class ApiWrapper

    attr_accessor :logger

    def self.from_url(url, api_key, jurisdiction_id=nil)
      resource = RestClient::Resource.new(url)
      return self.new(resource, api_key, jurisdiction_id)
    end

    def initialize(resource, api_key, jurisdiction_id=nil)
      @resource = resource
      @api_key = api_key
      @jurisdiction_id = jurisdiction_id
    end

    def log
      @logger ||= Easy311.logger
    end

    def all_services
      log.info "querying list of services"
      response = query_service('/services.json')
      return [] if response.empty?

      raw_services = JSON.parse(response)
      services = raw_services.map { |r| Service.new(r) }

      return services
    end

    def group_names
      all_services.map { |s| s.group }.uniq
    end

    def groups
      all_services.group_by { |s| s.group }
    end

    def attrs_from_code(code)
      log.info "querying attributes for service #{code}"
      url = "/services/#{code}.json"
      response = query_service(url)
      return [] if response.empty?

      json_data = JSON.parse(response)
      raw_attrs = json_data['attributes']
      return [] if raw_attrs.empty?

      attrs = raw_attrs.map { |a| Attribute.new(a) }

      return attrs
    end

    def services_with_attrs
      log.info "querying all services and attributes"
      services = all_services.map do |service|
        service.attrs = attrs_from_code(service.code)
        service
      end
      return services
    end

    def query_service(path)
      params = build_params
      log.debug "GET #{path}"
      response = @resource[path].get(params)
      log.debug "RESPONSE #{response}"
      return response.strip
    end

    def build_params
      params = {}
      params[:jurisdiction_id] = @jurisdiction_id unless @jurisdiction_id.nil?
      return params
    end

    def send_request(request)
      log.info "sending request #{request}"

      params = request.to_post_params
      params['api_key'] = @api_key
      log.debug "params #{params}"

      response = @resource['/requests.json'].post(params) do |http_response|
        log.debug "RESPONSE #{http_response.code} #{http_response.body}"
        if http_response.code.to_i >= 400
          parse_error_response(http_response.body)
        else
          parse_post_response(http_response.body)
        end
      end

      log.info "response #{response}"
      return response
    end

    def parse_post_response(body)
      json_response = JSON.parse(body)
      return Response.new(json_response.first)
    end

    def parse_error_response(body)
      json_response = JSON.parse(body)
      response = Response.new
      response.error_message = json_response.map { |r| r['description'] }.join(",")
      return response
    end

  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger ||= rails_logger || default_logger
  end

  def self.rails_logger
    defined?(::Rails) && ::Rails.respond_to?(:logger) && ::Rails.logger
  end

  def self.default_logger
    Logger.new(STDOUT)
  end
end
