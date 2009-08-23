# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatter/unicode' # Comment out this line if you don't want Cucumber Unicode support
Cucumber::Rails.use_transactional_fixtures
Cucumber::Rails.bypass_rescue # Comment out this line if you want Rails own error handling 
                              # (e.g. rescue_action_in_public / rescue_responses / rescue_from)

require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

Before do
  FileUtils.rm_r(APP_CONFIG[:git_root], :force => true)
  base = APP_CONFIG[:git_root].split(/\//)[0..-2].join("/")
  system("cd #{base} ; tar xfz test.tgz")
end

After do
  FileUtils.rm_r(APP_CONFIG[:git_root], :force => true)
end
require 'cucumber/rails/rspec'
require 'webrat/core/matchers'
