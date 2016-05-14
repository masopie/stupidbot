module Visjar
  module Commands
    class Locale
      def self.run(client, slack, recast)
        # Get informations about the request
        @language = recast.get('nationality') || recast.get('language')

        if @language.nil?
          client.send_message(slack['channel'], 'Woops, are you sure you provided your language?')
        else
          Config.language = @language
          client.send_message(slack['channel'], "Thanks, you'll now receive the news in '#{@language.raw.capitalize}'.")
        end
      end

      Commands.register('locale', self)
    end
  end
end
