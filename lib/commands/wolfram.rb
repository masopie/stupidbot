module Visjar
  module Commands
    class Wolfram
      def self.run(client, slack, recast)
        response = HTTParty.get("http://api.wolframalpha.com/v2/query?input=#{slack["text"]}&appid=V68RPP-53H3P99KEW")
        data = response.parsed_response
        Log.info("#{data}")
        pod = data["queryresult"]["pod"][0..-2]
        p pod

        client.send_message(slack["channel"], title)
        client.send_message(slack["channel"], image)
        client.send_message(slack["channel"], result)
      end


      Commands.register("wolfram", self)
    end
  end
end
