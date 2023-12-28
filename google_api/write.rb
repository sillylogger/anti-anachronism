require 'googleauth'
require 'googleauth/stores/file_token_store'

module GoogleAPI
  class Write
    include Singleton

    attr_accessor :client

    def initialize
      @client = GoogleAPI::Client.new(:write)
      @client.authorize!
      @client.refresh!
    end

    def self.authorization_header
      "Bearer #{instance.client.access_token}"
    end
  end
end

