#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require 'bundler/setup'
require "bunny"

conn = Bunny.new
conn.start

ch = conn.create_channel
q  = ch.queue("bunny.examples.hello_world", :auto_delete => true)
x  = ch.default_exchange
wake = false
t = Thread.current
q.subscribe do |delivery_info, metadata, payload|

	puts "Received #{payload}"

	if "exit".eql? payload and t.status.eql? 'sleep' 
		t.wakeup
	end
end

puts "await for messages sleeping"
sleep


puts "i'm done"
conn.close