module Visjar
  module Commands
    class Search
      def self.run(client, slack, recast)
        response = HTTParty.get("https://www.googleapis.com/customsearch/v1?key=#{Config.google_key}&cx=#{Config.google_cx}&q=#{recast.source}")
        response = JSON.parse(response.body)

        if response['searchInformation']['totalResults'].to_i > 0
          result = response['items'][0] if response['items'] && response['items'].any?

          client.send_message(slack['channel'], "#{result['title']}\n#{result['link']}")
        else
          client.send_message(slack['channel'], 'Wow, I found nothing about your request on the internet. Sorry about that.')
        end
      end

      Commands.register('search', self) unless Config.google_key.nil? || Config.google_cx.nil?
    end
  end
end
