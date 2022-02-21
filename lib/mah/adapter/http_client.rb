module Mah
  module Adapter
    class HttpClient
	    attr_reader :session

      def initialize
        @mah_config = Config.load_and_set_settings("../../../config/settings.yaml")[:mah]
        @logger = Logger.new(STDOUT)
        @url = "http://#{@mah_config["host"]}#{":#{@mah_config["port"]["http"]}" if @mah_config["port"]["http"]}"
        @conn = Faraday.new(url: @url, headers: {"Content-Type" => "application/json"}) do |f|
          f.request :json
          f.response :json
        end
      end

      def verify
        response = @conn.post(@url + "/verify") do |req|
          req.body = {verifyKey: @mah_config["verifyKey"]}.to_json
        end
        if response.body["code"] == 0
	        @session = response.body["session"]
	        @logger.info "Authentication key verification successful."
        else
          raise(response.body["msg"])
        end
      end

      def bind
	      response = @conn.post(@url + "/bind") do |req|
		      req.body = {
			      sessionKey: @session,
			      qq: @mah_config["account"]
		      }.to_json
	      end
	      if response.body["code"] == 0
		      @logger.info "Session key activation successful."
	      else
		      raise(response.body["msg"])
	      end
      end

      def release
	      response = @conn.post(@url + "/release") do |req|
		      req.body = {
			      sessionKey: @session,
			      qq: @mah_config["account"]
		      }.to_json
	      end
	      if response.body["code"] == 0
		      @logger.info "Session release successful."
	      else
		      raise(response.body["msg"])
	      end
      end
    end
  end
end

require "config"
require "faraday"
require "logger"

a = Mah::Adapter::HttpClient.new
a.verify
a.bind
a.release
