#!/usr/bin/env ruby
# encoding: utf-8
require "rubygems"
require "bunny"
require 'sinatra'
require 'byebug'

get '/exit' do
  conn = Bunny.new
	conn.start

ch = conn.create_channel
q  = ch.queue("bunny.examples.hello_world", :auto_delete => true)
x  = ch.default_exchange

x.publish("exit", :routing_key => q.name)

conn.close
end

post '/rabbit' do
  conn = Bunny.new
	conn.start

ch = conn.create_channel
q  = ch.queue("bunny.examples.hello_world", :auto_delete => true)
x  = ch.default_exchange

req_payload = request.body.read
x.publish(req_payload, :routing_key => q.name)

conn.close
end