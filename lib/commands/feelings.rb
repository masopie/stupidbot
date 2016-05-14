module Visjar
  module Commands
    class Feelings
      @answers = YAML.load_file(File.join(File.dirname(__FILE__), '../../config/answers.yml'))['feelings']

      def self.run(client, slack, _)
        client.send_message(slack['channel'], @answers.sample)
      end

      Commands.register('feelings', self)
    end
  end
end
