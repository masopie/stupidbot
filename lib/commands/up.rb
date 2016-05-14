require 'httparty'

module Visjar
  module Commands
    class Up
      def self.run(client, slack, recast)
        # Get informations about the request
        @url = recast.get('url')

        if @url.nil?
          client.send_message(slack['channel'], "Sorry, I didn't understand the site you want me to check.")
        else
          response = HTTParty.get(@url.value)
          if response.code != 200
            client.send_message(slack['channel'], "Looks like #{@url.value} is down from here.", unfurl_links: false)
          else
            client.send_message(slack['channel'], "#{@url.value} seems up.", unfurl_links: false)
          end
        end
      rescue StandardError
        client.send_message(slack['channel'], "Looks like #{@url.value} is down from here.", unfurl_links: false)
      end

      Commands.register('up', self)
    end
  end
end
