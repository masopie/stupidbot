module Visjar
  module Commands
    class Compliments
      @answers = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['compliments']

      def self.run(client, slack, _)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands.register('compliments', self)
    end
  end
end
