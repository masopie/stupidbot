module Visjar
  module Commands
    class Inspiration
      @answers = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['inspiration']

      def self.run(client, slack, _)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands.register('inspiration', self)
    end
  end
end
