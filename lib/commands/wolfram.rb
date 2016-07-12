module Visjar
  module Commands
    class Wolfram
      def self.run(client, slack, recast)
        response = HTTParty.get("http://api.wolframalpha.com/v2/query?input=#{slack["text"]}&appid=V68RPP-53H3P99KEW")
        data = response.parsed_response
        Log.info("#{data}")
        pod = data["queryresult"]["pod"][0..-2]
        p pod

        pod.each do |subpod|
          title = subpod["title"]
          image = subpod["subpod"]["img"]["src"]
          result = subpod["subpod"]["plaintext"]

          if title == nil
            title = " "
          end

          if image == nil
            image = " "
          end

          if result == nil
            result = " "
          end

          client.send_message(slack["channel"], title)
          client.send_message(slack["channel"], image)
          client.send_message(slack["channel"], result)
        end

      end


      Commands.register("wolfram", self)
    end
  end
end
