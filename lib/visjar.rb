# encoding: utf-8

module Visjar
  class Visjar
    def initialize
      @answers       = YAML.load_file(File.join(File.dirname(__FILE__), '../config/answers.yml'))['unknown']
      @slack_client  = Slack::RealTime::Client.new
      @recast_client = RecastAI::Client.new(Config.recast_key)
    end

    def init!
      # On connexion, log
      @slack_client.on(:hello) do |_|
        Log.info("#{self.class} | Connected as '#{Config.names.first}' to #{Config.url}")
        Log.info("#{self.class} | Using #{Commands.commands.keys.join(', ')}.")
      end

      @slack_client.on([:channel_joined, :group_joined]) do |slack|
        Log.info("#{self.class} | Joined '#{slack['channel']['name']}'")
        Commands::Help.run(@slack_client, { 'channel' => slack['channel']['id'] }, nil)
      end

      # On message, check if its for us, then invoke the appropriate command
      @slack_client.on(:message) do |slack|
        explicit = !slack['text'].nil? && !slack['text'].match(/^<@#{Config.id}>:?\s?/).nil? # "@visjar do something" (ping)
        implicit = Config.ims.any?{ |im| im['id'] == slack['channel'] } # "do something" (MP)

        if !slack['user'].nil? && slack['user'] != Config.id && (explicit || implicit)
          # Remove Visjar's name from the sentence in order to be processed by Recast.AI
          slack['text'].gsub!(/^<@#{Config.id}>:?\s?/, '')

          recast = @recast_client.text_request(slack['text'])
          Log.info("#{self.class} | Received '#{recast.source}' tagged as '#{recast.intent.nil? ? 'nothing' : recast.intent}', as '#{explicit ? 'explicit' : 'implicit'}'.")

          if recast.intents.any?
            Commands.invoke(@slack_client, slack, recast)
          elsif ['what', 'where', 'who', 'when', 'how', 'why'].include?(recast.sentence.type)
            Commands::Search.run(@slack_client, slack, recast)
          else
            @slack_client.send_message(slack['channel'], @answers.sample)
          end
        end
      end

      # On error, log
      @slack_client.on(:error) do |slack|
        Log.error("#{self.class} | #{slack}")
      end
    end

    def run!
      # Get the auth infos for the user
      auth = @slack_client.web_client.auth_test

      # Set the config from the response
      Config.url     = auth['url']
      Config.id      = auth['user_id']
      Config.team    = auth['team']
      Config.team_id = auth['team_id']
      Config.names   = [auth['user'], "#{auth['user']}:", "<@#{auth['user_id']}>", "<@#{auth['user_id']}>:"]
      Config.ims     = @slack_client.web_client.im_list['ims']

      # Start the client
      @slack_client.start!
    end
  end
end
