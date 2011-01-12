require 'rest_client'
require 'crack'

module Api
  class Base

    def initialize(options = {})
      @api_version = options[:api_version] || "v1"
      @name_key = options[:client_name_key]
      @environment = options[:env] || :development
      @ssl = options[:ssl] || false
      @format = options[:format] || :json

      if @environment == :development
        warn "#{"!"*5} #{"*"*88} #{"!"*5}"
        warn "#{"!"*5} You are running using the development environment!#{" "*38}#{"!"*5}"
        warn "#{"!"*5} #{"*"*88} #{"!"*5}"
      end
      if @name_key.nil?
        raise "You must specify a valid client name key!"
      end
    end

    def get(query_target, query_params = {}, paging_params = {})
      paging_params = {:page => 1, :per_page => 25} if paging_params.empty?
      parameters = Hash["q", query_params].merge(paging_params)
      uri = URI::HTTP.build({:host => get_api_host, :port => @ssl ? 443 : 80,
                             :path => query_target.gsub(":format", @format.to_s),
                            :query => parameters.to_query})
      puts "-"*100
      puts uri.to_s
      puts "-"*100

      response = RestClient.get(uri.to_s)
      xml_response = Crack::XML.parse(response.body)
      if !xml_response["nil_classes"].nil? && xml_response["nil_classes"].blank?
        return nil
      end

      @format == :json ? ActiveSupport::JSON.decode(response.body) : xml_response
    end

    private

    def get_api_host
      @environment == :production ? "#{@name_key}.api.gov-i.com" : "#{@name_key}.api.govinteract.info"
    end
  end

  class Resources
    class Content
      PRESS_RELEASES = "/content/press-releases.:format"
      EVENTS = "/content/events.:format"
      NOTICES = "/content/notices.:format"
      DOWNLOADS = "/content/downloads.:format"
      PHOTOS = "/content/photos.:format"
      FAQS = "/content/faqs.:format"
      LINKS = "/content/links.:format"
      MEETINGS = "/content/meetings.:format"
      WEB_CONTENT = "/content/website.:format"
    end
  end
end
