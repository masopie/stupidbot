require 'httparty'
require 'json'

module Visjar
  module Commands
    class Eat
      def self.run(client, slack, recast)
        # Get informations about the request, or fallbacks if nil
        @location = recast.get('location') || Config.location
        @sort     = recast.get('sort') || RecastAI::Entity.new('sort', { 'value' => nil, 'raw' => nil })
        @type     = get_type(recast.source) || 'restaurant'

        # Notify the user of the current research.
        client.send_message(slack['channel'], "Looking for #{@sort.raw.nil? ? '' : "the #{@sort.raw}"} #{@type.pluralize} in a 1km radius around #{@location.raw.titleize}.")

        # Perfom the places search.
        response = if @type == 'restaurant'
                     JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@location.lat},#{@location.lng}&radius=1000&types=food&key=#{Config.google_key}").body)
                   else
                     JSON.parse(HTTParty.get("https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{@type}&location=#{@location.lat},#{@location.lng}&radius=1000&types=food&key=#{Config.google_key}").body)
                   end

        if response['status'] == 'OK'
          # Sort by the criterion of the user
          case @sort.raw
          when 'best', 'most popular'
            response['results'].sort_by!{ |a| a['rating'] ? a['rating'] : -10 }.reverse!
          when 'worst', 'least popular'
            response['results'].sort_by!{ |a| a['rating'] ? a['rating'] : 10 }
          when 'costliest', 'fanciest', 'most expensive'
            response['results'].sort_by!{ |a| a['price_level'] ? a['price_level'] : -10 }.reverse!
          when 'cheapest', 'least expensive', 'most affordable'
            response['results'].sort_by!{ |a| a['price_level'] ? a['price_level'] : 10 }
          else
            response['results'].shuffle!
          end

          found = 0
          response['results'].each do |restau|
            p2 = { 'lat' => restau['geometry']['location']['lat'], 'lng' => restau['geometry']['location']['lng'] }

            rating = "#{restau['rating'] ? restau['rating'].to_f.round : '?'}/5"
            client.send_message(slack['channel'], "*#{restau['name']}*\n #{rating} (<https://maps.googleapis.com/maps/api/staticmap?size=600x300&maptype=roadmap&markers=color:green%7Clabel:A%7C#{p2['lat']},#{p2['lng']}&key=#{Config.google_key}|map>)", unfurl_media: false)

            found += 1
            break if found >= Config.limit_eat
          end
        else
          client.send_message(slack['channel'], "Sorry, I could not find any restaurant near #{@location.raw.titleize}...")
        end
      end

      # Helper to get the type criterion
      def self.get_type(sentence)
        sentence.split(/\s+|\;|\,}\:|\(|\)/).each do |w|
          return w if Utils::TYPES.include?(w.downcase)
        end

        nil
      end

      Commands.register('eat', self) unless Config.location.nil? || Config.google_key.nil? || Config.limit_eat.nil?
    end
  end
end
