module Visjar
  module Commands
    class Reaction
      @answers = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['reaction']

      def self.run(client, slack, _)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands.register('reaction', self)
    end
  end
end
