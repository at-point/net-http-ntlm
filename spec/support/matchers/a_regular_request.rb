# frozen_string_literal: true

RSpec::Matchers.define :a_regular_request do
  match do |request|
    authorization_header = request['authorization']
    authorization_header.nil? || !authorization_header.match?(/NTLM .+/)
  end

  description do
    'a regular request without NTLM authorization header'
  end
end
