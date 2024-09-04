require 'jwt'

class JwtAuth
  ALGORITHM = 'HS256'

  def self.encode(payload)
    JWT.encode(payload, auth_secret, ALGORITHM)
  end

  def self.decode(auth_token)
    JWT.decode(auth_token, auth_secret, true, { algorithm: ALGORITHM })&.first rescue nil
  end

  def self.auth_secret
     # jwt auth secret
    ENV['AUTH_SECRET'] ||= "Z\\\ag*N\xFA\xF6\t\xE6-\x92\x1A`\xBF|\xC0\xE9r*\x8B\x96\bR\riE \xC0\xC4\x14\a"
  end
end