# encoding: utf-8

module Visjar
  class Utils
    # Versioning
    MAJOR   = '1'.freeze
    MINOR   = '0'.freeze
    MICRO   = '1'.freeze
    VERSION = "#{MAJOR}.#{MINOR}.#{MICRO}".freeze

    # Endpoints
    RECAST_ENDPOINT = 'https://api.recast.ai/v1/request'.freeze

    # Dirty hack because RecastAI can't detect food types just yet :(
    TYPES = [
      'pizza',
      'crepe',
      'creperie',
      'burger',
      'sushi',
      'pasta',
      'kebab',
      'steak',
      'salad',
      'sandwich',
      'italian',
      'chinese',
      'japanese',
      'lebanese',
      'french',
      'korean',
      'german',
      'vegan',
      'vegetarian',
      'meat'
    ].freeze
  end
end

# Those are monkey-patches for slack-ruby-client's realtime client.
module Slack
  module RealTime
    class Client
      # The realtime client allow us to work on events, but we couldn't make the text formatting work.
      # Thus, we are using the web_client for message formatting.
      def send_message(channel, text, options = {})
        self.web_client.chat_postMessage({ channel: channel, text: text, as_user: true }.merge(options))
      end

      # This patch allows us to bind several events with one call
      def on(type, &block)
        if type.is_a?(Array)
          type.each do |t|
            callbacks[t.to_s] << block
          end
        else
          callbacks[type.to_s] << block
        end
      end
    end
  end
end
