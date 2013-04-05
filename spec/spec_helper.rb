begin
  require 'bundler/setup'
rescue LoadError
  puts 'Use of Bundler is recommended'
end

require 'rspec'
require 'net/https'
require 'em-http'

require File.expand_path("../../lib/keen", __FILE__)

module Keen::SpecHelpers
  def stub_keen_request(method, url, status, response_body)
    stub_request(method, url).to_return(:status => status, :body => response_body)
  end

  def stub_keen_post(url, status, response_body)
    stub_keen_request(:post, url, status, MultiJson.encode(response_body))
  end

  def stub_keen_get(url, status, response_body)
    stub_keen_request(:get, url, status, MultiJson.encode(response_body))
  end

  def expect_keen_request(method, url, body, sync_or_async_ua)
    user_agent = "keen-gem, v#{Keen::VERSION}, #{sync_or_async_ua}"
    user_agent += ", #{RUBY_VERSION}, #{RUBY_PLATFORM}, #{RUBY_PATCHLEVEL}"
    if defined?(RUBY_ENGINE)
      user_agent += ", #{RUBY_ENGINE}"
    end

    WebMock.should have_requested(method, url).with(
      :body => body,
      :headers => { "Content-Type" => "application/json",
                    "User-Agent" => user_agent })

  end

  def expect_keen_get(url, sync_or_async_ua)
    expect_keen_request(:get, url, "", sync_or_async_ua)
  end

  def expect_keen_post(url, event_properties, sync_or_async_ua)
    expect_keen_request(:post, url, MultiJson.encode(event_properties), sync_or_async_ua)
  end

  def api_event_resource_url(collection)
    "https://api.keen.io/3.0/projects/#{project_id}/events/#{collection}"
  end
end

RSpec.configure do |config|
  config.include(Keen::SpecHelpers)
end

