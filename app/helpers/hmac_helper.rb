module HmacHelper

  def encode(base)
    require 'base64'
    require 'hmac-sha1'

    key="79m7j#daV&q8eF"
  	result = Base64.encode64((HMAC::SHA1.new(key) << base).digest).strip
  	return result
  end

end

	# Uso:
  # => a = encode("abcd12345","GET534960ccc88ee69029cd3fb2")
  # => puts a
