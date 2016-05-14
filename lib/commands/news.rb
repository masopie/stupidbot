module Visjar
  module Commands
    class News
      def self.run(client, slack, recast)
        # Get informations about the request
        @language = recast.get('nationality') || recast.get('language') || Config.language

        response = JSON.parse(HTTParty.get("http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=#{Config.limit_news}&q=https%3A%2F%2Fnews.google.com%2Fnews%3Fned%3D#{@language.code}%26output%3Drss%26sort%3Ddate").body)
        if response['responseStatus'] == 200
          news = response['responseData']['feed']
          news['entries'].each do |entry|
            link  = entry['link'][entry['link'].rindex('&url=') + 5..-1]
            title = entry['title'][0..entry['title'].rindex(' - ') - 1]

            client.send_message(slack['channel'], "<#{link}|#{title}> - _#{DateTime.parse(entry['publishedDate']).strftime('%c')}_", unfurl_links: false, unfurl_media: false)
          end
        else
          client.send_message(slack['channel'], 'Oups, I had troubles fetching the news for you... Try again later!')
        end
      end

      Commands.register('news', self) unless Config.language.nil? || Config.limit_news.nil?
    end
  end
end
