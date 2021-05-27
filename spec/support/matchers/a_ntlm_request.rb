# frozen_string_literal: true

RSpec::Matchers.define :a_ntlm_request do |expected_message_type|
  match do |request|
    authorization_header = request['authorization']
    break false unless authorization_header&.match?(/NTLM .+/)

    message = Net::NTLM::Message.decode64(authorization_header.slice(/NTLM (.+)/, 1))
    message.is_a?(expected_message_type)
  end

  description do
    "a NTLM authorization header of #{expected_message_type.name}"
  end
end
