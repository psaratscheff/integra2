require 'base64'
require 'hmac-sha1'

Base64.encode64((HMAC::SHA1.new('key') << 'base').digest).strip

def encode(key, base)
	result = Base64.encode64((HMAC::SHA1.new(key) << base).digest).strip
	print result,"\n"
	return result
end

#a = encode("abcd12345","GET534960ccc88ee69029cd3fb2")
#print a,"\n"
