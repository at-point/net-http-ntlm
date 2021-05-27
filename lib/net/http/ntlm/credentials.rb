# frozen_string_literal: true

# Manages the credentials on Net::HTTP request objects
module Net::HTTP::NTLM::Credentials
  def self.included(base)
    base.attr_reader :ntlm_auth_domain, :ntlm_auth_user, :ntlm_auth_password
    super
  end

  # Sets the NTLM credentials on a request
  #
  # @param user [String] Username
  # @param domain [String] NT-Domain
  # @param password [String] Password
  def ntlm_auth(user, domain, password)
    @ntlm_auth_user = user
    @ntlm_auth_domain = domain
    @ntlm_auth_password = password
  end

  # Returns the NTLM credentials as a hash
  #
  # @return [Hash] Hash with user, domain, password
  def ntlm_auth_params
    {
      user: ntlm_auth_user,
      domain: ntlm_auth_domain,
      password: ntlm_auth_password
    }
  end
end
