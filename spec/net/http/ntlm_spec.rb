# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Net::HTTP::NTLM do
  let(:endpoint) { URI('http://example.org/') }
  let(:user) { 'john' }
  let(:domain) { 'EXAMPLE' }
  let(:password) { 's3cr3t' }
  let(:http) { Net::HTTP.new(endpoint.host, endpoint.port) }
  let(:challenge) { 'NTLM TlRMTVNTUAACAAAABwAHADgAAAAGgokCYFitDKoX0OAAAAAAAAAAAJYAlgA/AAAACgA5OAAAAA9BVFBPSU5UAgAOAEEAVABQAE8ASQBOAFQAAQAQAEUAWABDAEgAQQBOAEcARQAEABYAYQB0AHAAbwBpAG4AdAAuAGQAZQB2AAMAKABlAHgAYwBoAGEAbgBnAGUALgBhAHQAcABvAGkAbgB0AC4AZABlAHYABQAWAGEAdABwAG8AaQBuAHQALgBkAGUAdgAHAAgAQnleU4RR1wEAAAAA' }
  let(:authenticated_response) { Net::HTTPOK.new('1.1', '200', 'OK') }
  let(:challenge_response) do
    res = Net::HTTPUnauthorized.new('1.1', '401', 'Unauthorized')
    res['www-authenticate'] = challenge
    res
  end

  it 'has a version number' do
    expect(Net::HTTP::NTLM::VERSION).not_to be nil
  end

  [
    Net::HTTP::Copy,
    Net::HTTP::Delete,
    Net::HTTP::Get,
    Net::HTTP::Head,
    Net::HTTP::Lock,
    Net::HTTP::Mkcol,
    Net::HTTP::Move,
    Net::HTTP::Options,
    Net::HTTP::Patch,
    Net::HTTP::Post,
    Net::HTTP::Propfind,
    Net::HTTP::Proppatch,
    Net::HTTP::Put,
    Net::HTTP::Trace,
    Net::HTTP::Unlock
  ].each do |verb|
    context verb.name do
      let(:request) { verb.new(endpoint.request_uri) }

      describe '#ntlm_auth' do
        it 'sets the user, domain, password and ntlm_auth_params' do
          expect { request.ntlm_auth(user, domain, password) }.to(
            change(request, :ntlm_auth_user).from(nil).to(user).and(
              change(request, :ntlm_auth_domain).from(nil).to(domain).and(
                change(request, :ntlm_auth_password).from(nil).to(password).and(
                  change(request, :ntlm_auth_params).from(
                    { user: nil, domain: nil, password: nil }
                  ).to({ user: user, domain: domain, password: password })
                )
              )
            )
          )
        end
      end

      context 'no authentication and no credentials' do
        it 'does not negotiate' do
          expect(http).to receive(:request_without_ntlm_auth).with(a_regular_request, any_args).once.and_return(authenticated_response)

          response = http.request(request)
          expect(response).to be_a Net::HTTPOK
        end
      end

      context 'no authentication and credentials' do
        before { request.ntlm_auth(user, domain, password) }

        it 'does negotiate' do
          expect(http).to receive(:request_without_ntlm_auth).with(a_ntlm_request(Net::NTLM::Message::Type1), any_args).once.and_return(authenticated_response)

          response = http.request(request)
          expect(response).to be_a Net::HTTPOK
        end
      end

      context 'authentication and no credentials' do
        it 'does not negotiate and returns the response' do
          expect(http).to receive(:request_without_ntlm_auth).with(a_regular_request, any_args).once.and_return(challenge_response)

          response = http.request(request)
          expect(response).to be_a Net::HTTPUnauthorized
        end
      end

      context 'authentication and credentials' do
        before { request.ntlm_auth(user, domain, password) }

        it 'does negotiate and authenticate' do
          expect(http).to receive(:request_without_ntlm_auth).with(a_ntlm_request(Net::NTLM::Message::Type1), any_args).ordered.and_return(challenge_response)
          expect(http).to receive(:request_without_ntlm_auth).with(a_ntlm_request(Net::NTLM::Message::Type3), any_args).ordered.and_return(authenticated_response)

          response = http.request(request)
          expect(response).to be_a Net::HTTPOK
        end
      end
    end
  end
end
