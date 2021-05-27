# frozen_string_literal: true

require 'net/http'
require 'rubyntlm'

require 'net/http/ntlm/version'
require 'net/http/ntlm/credentials'
require 'net/http/ntlm/transport'

# Adds NTLM authentication to Net::HTTP
module Net::HTTP::NTLM
end

Net::HTTPGenericRequest.include(Net::HTTP::NTLM::Credentials)
Net::HTTP.include(Net::HTTP::NTLM::Transport)
