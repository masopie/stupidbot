module Visjar
  module Commands
    class Insults
      @answers = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['insults']

      def self.run(client, slack, _)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands.register('insults', self)
    end
  end
end
