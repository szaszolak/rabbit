#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'bundler/setup'
require "bunny"

begin
	conn = Bunny.new
	conn.start
rescue Bunny::TCPConnectionFailed
	puts "can not connect to RabbitMQ server, script will stop executing"
	exit
end

ch = conn.create_channel
queue  = ch.queue("hungry rabbit eater", :auto_delete => true)
ex  = ch.topic("rabbit_meals", :auto_delete => true)

t = Thread.current

queue.bind(ex, :routing_key => "meal.#").subscribe do |delivery_info, metadata, payload|

	puts "Received #{payload}"

	if "exit".eql? payload and t.status.eql? 'sleep' 
		t.wakeup
	end
end

puts "await for messages"
sleep


puts "i'm done"
conn.close