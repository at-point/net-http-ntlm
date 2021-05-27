# net-http-ntlm
Adds NTLM authentication to HTTP requests using the rubyntlm gem.
A drop-in replacement for ruby-ntlm with NTLMv2 support.

NTLM authentication is used in Microsoft's server products,
such as MS Exchange Server and IIS.

Install
-------

```sh
$ sudo gem install net-http-ntlm
```

If you'd rather install net-http-ntlm using `bundler`, add a line for it in your Gemfile:

```rb
gem 'net-http-ntlm'
```

Usage
-----

```rb
require 'ntlm/http'
http = Net::HTTP.new('www.example.com')
request = Net::HTTP::Get.new('/')
request.ntlm_auth('User', 'Domain', 'Password')
response = http.request(request)
```

References
----------

 * rubyntlm: https://github.com/WinRb/rubyntlm
 * ruby-ntlm: https://github.com/macks/ruby-ntlm