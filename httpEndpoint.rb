#!/usr/bin/env ruby
# encoding: utf-8
require "rubygems"
require 'bundler/setup'
require "bunny"
require 'sinatra'
require 'sinatra/config_file'
require 'byebug'

config_file 'config/config.yml'
before { 	env['rack.logger'] = Logger.new("#{settings.root}/log/#{settings.environment}.log",'weekly')}


class BunnyCache
  def self.init(params)
  	@@conn_params = params
   	@@client = nil
	@@rabbit_meals_exchange = nil
  end

	def self.client
	  unless @@client
	    conn = Bunny.new(@@conn_params)
	    conn.start
	    @@client=conn.create_channel
	  end
	  @@client
	end

 	def self.rabbit_meals_exchange	
		@@rabbit_meals_exchange ||= client.topic("rabbit_meals", :auto_delete => true)
	end
end



def conn_params
	return {
	  :host      => settings.rabbitHost,
	  :port      => settings.rabbitPort,
	  :ssl       => settings.rabbitSsl,
	  :vhost     => settings.rabbitVhost,
	  :user      => settings.rabbitUser,
	  :pass      => settings.rabbitPass,
	  :heartbeat => settings.rabbitHeartbeat, 
	  :frame_max => settings.rabbitFrame_max,
	  :auth_mechanism => settings.rabbitAuth_mechanism
	}
end


configure do
  
	BunnyCache::init(conn_params)
end



post '/rabbit' do
	begin
		req_payload = request.body.read
		BunnyCache.rabbit_meals_exchange.publish(req_payload, :routing_key => "meal")
		response.status = 200
	rescue Bunny::Exception
		logger.info "Bunny exception occured"
		response.status = 500
	end
end