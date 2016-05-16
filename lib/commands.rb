# encoding: utf-8

module Visjar
  module Commands
    @commands = {}

    def self.invoke(client, slack, recast)
      @commands.each_pair do |route, klass|
        Log.info("#{route} - #{klass}")
        klass.run(client, slack, recast) if route == recast.intent
      end
    rescue StandardError => e
      client.send_message(slack['channel'], "BEEP DERP BOOP DORP. Sorry, I can't handle this request now, but my team is working to fix it!")

      Log.error("#{e.class}: #{e}")
      Log.error(e.backtrace)
    end

    def self.register(route, klass)
      @commands[route] = klass
    end

    def self.commands
      @commands
    end
  end
end
