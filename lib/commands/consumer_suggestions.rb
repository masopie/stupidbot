module Visjar
  module Commands
    class ConsumerSuggestions
      @answers = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['consumer_suggestions']

      def self.run(client, slack, _)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands.register('consumer_suggestions', self)
    end
  end
end
