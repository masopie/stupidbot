module Visjar
  module Commands
    class Weather
      @icons = {
        'clear-day'           => ':sunny:',
        'clear-night'         => ':full_moon:',
        'rain'                => ':rain_cloud:',
        'snow'                => ':snow_cloud:',
        'sleet'               => ':wavy_dash:',
        'wind'                => ':dash:',
        'fog'                 => ':fog:',
        'cloudy'              => ':cloud:',
        'partly-cloudy-day'   => ':sunny::cloud:',
        'partly-cloudy-night' => ':full_moon::cloud:',
        'thunderstorm'        => ':lightning_cloud:',
        'tornado'             => ':tornado_cloud:'
      }

      def self.run(client, slack, recast)
        # Get informations about the request
        @location = recast.get('location') || Config.location
        @datetime = recast.get('datetime') || RecastAI::Entity.new('datetime', 'value' => Time.now.to_i, 'raw' => 'today')
        @duration = recast.get('duration')

        if @duration.nil?
          forecast = ForecastIO.forecast(@location.lat, @location.lng, params: { units: 'ca' }, time: @datetime.value)
          answer   = generate_answer(recast, forecast.currently)

          client.send_message(slack['channel'], answer)
        else
          client.send_message(slack['channel'], "Sorry, I can't handle time spans just yet!")
        end
      end

      def self.generate_answer(recast, forecast)
        text = ''

        # Datetime
        text << @datetime.raw.capitalize

        # Temperature
        text << " #{forecast.temperature.to_f.round(1)}°C"

        # Precipitation
        text << " with a #{(forecast.precipProbability.to_f * 100).round}% probability of #{forecast.precipType}" unless forecast.precipProbability.nil? || forecast.precipProbability <= 0.10

        # Wind
        case forecast.windSpeed
        when 0..5
          text << ' without wind'
        when 5..15
          text << ' with a light breeze'
        when 15..30
          text << ' with wind'
        when 30..60
          text << ' with violent wind'
        when 60..999
          text << ' with a storm'
        end

        # Convert forecast icons to slack icons
        text << " (#{@icons[forecast.icon]})"

        # Location
        text << " in #{@location.raw.titleize}"

        text
      end

      Commands.register('weather', self) unless Config.google_key.nil? || ForecastIO.api_key.nil?
    end
  end
end
