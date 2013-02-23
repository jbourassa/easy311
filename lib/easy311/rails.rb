module Easy311
  module Rails

    CACHE_KEY = 'easy311_services'

    def self.config_path
      "#{::Rails.root}/config/easy311.yml"
    end

    def self.load_config
      YAML.load(ERB.new(IO.read(config_path)).result)
    end

    def self.load_all_services!
      api_wrapper = self.api_wrapper
      services = api_wrapper.services_with_attrs

      ::Rails.cache.write CACHE_KEY, services
    end

    def self.all_services
      ::Rails.cache.read(CACHE_KEY) || load_all_services!
    end

    def self.api_wrapper
      api_config = load_config
      url = api_config['url']
      jurisdiction_id = api_config['jurisdiction_id']
      api_key = api_config['apikey']

      ApiWrapper.from_url(url, api_key, jurisdiction_id)
    end

  end
end
