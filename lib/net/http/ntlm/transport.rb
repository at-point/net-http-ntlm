# frozen_string_literal: true

# Overloads the request method of Net::HTTP
module Net::HTTP::NTLM::Transport
  def self.included(base)
    base.alias_method :request_without_ntlm_auth, :request
    base.alias_method :request, :request_with_ntlm
  end

  # Replaces the original request method, and tries to negotiate an NTLM authentication
  #
  # @param req [Net::HTTPGenericRequest] A Net::HTTP request
  # @param body [String] Request body
  # @yield [Net::HTTPResponse] Passes the HTTP response object to the block
  # @return [Net::HTTPResponse] The HTTP response object
  def request_with_ntlm(req, body = nil, &block) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
    # If we don't have NTLM credentials, handle as regular request
    return request_without_ntlm_auth(req, body, &block) unless req.ntlm_auth_user

    unless started?
      @original_body = req.body
      req.body = nil
      start do
        req.delete('connection')
        return request_with_ntlm(req, body, &block)
      end
    end

    # Try to negotiate NTLM first
    negotiation_message = Net::NTLM::Message::Type1.new
    negotiation_message.domain = req.ntlm_auth_domain
    req['authorization'] = "NTLM #{negotiation_message.encode64}"
    res = request_without_ntlm_auth(req, body)

    # Try to extract NTLM challenge from the response
    www_auth_headers = Array(res.get_fields('www-authenticate'))
    ntlm_challenge_header = www_auth_headers.find { |h| h.start_with?('NTLM') }
    challenge = ntlm_challenge_header&.slice(/NTLM (.*)/, 1)

    if challenge && res.code == '401'
      # We got a challenge and correct response code, sending an authorized request
      challenge_message = ::Net::NTLM::Message.decode64(challenge)
      authorization_message = challenge_message.response(req.ntlm_auth_params, ntlmv2: true)
      req['authorization'] = "NTLM #{authorization_message.encode64}"
      # We must re-use the connection.
      req.body_stream&.rewind
      req.body = @original_body
      request_without_ntlm_auth(req, body, &block)
    else
      # If we can't find a challenge or no authentication is required, return the response.
      yield res if block_given?
      res
    end
  end
end
