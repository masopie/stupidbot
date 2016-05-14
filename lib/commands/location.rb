module Visjar
  module Commands
    class Location
      def self.run(client, slack, recast)
        # Get informations about the request
        @location = recast.get('location')

        if @location.nil?
          client.send_message(slack['channel'], 'Woops, are you sure you provided your location?')
        else
          Config.location = @location
          client.send_message(slack['channel'], "Thanks, I'll now use '#{@location.raw.titleize}' for the weather and the restaurants.")
        end
      end

      Commands.register('location', self)
    end
  end
end
