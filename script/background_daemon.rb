#!/usr/bin/env ruby

require 'rubygems'

root_dir = File.expand_path('../')

Dir.chdir root_dir
require root_dir + '/config/environment'
Rails.logger = Logger.new(Rails.root.join('log', 'background_daemon.log'))
Rails.logger.auto_flushing = true if Rails.logger.respond_to? :auto_flushing=
ActiveRecord::Base.connection_config[:pool] = 25

task = SubmissionProcessorTask.new

loop do
  begin
    task.run
  rescue StandardError => e
    Rails.logger.error "Failed to send submission to sandbox: #{e}"
  end

  sleep task.wait_delay
end
