require "awscr-signer"

module Awscr
  module SSM
    class Api
      def initialize(@region : String, @credential : Credentials)
      end

      def uri
        URI.parse("https://ssm.#{@region}.amazonaws.com")
      end

      def client
        client = HTTP::Client.new(uri)
        client.before_request do |request|
          signer = Awscr::Signer::Signers::V4.new("ssm", @region, @credential.key, @credential.secret)
          # Attach session token header if present (required for temporary credentials)
          if token = @credential.session_token
            request.headers["X-Amz-Security-Token"] = token
          end
          signer.sign(request)
        end
        client
      end

      def request(r : Request)
        case r.method
        when "POST"
          client.post(path: "/", form: r.to_parameters)
        else
          HTTP::Client::Response.new(415)
        end
      end
    end
  end
end
