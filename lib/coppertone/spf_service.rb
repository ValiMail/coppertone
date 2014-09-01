module Coppertone
  # Service interface for SPF authentication
  class SpfService
    def self.authenticate_email(ip_as_s, sender, helo_domain, options = {})
      req = Coppertone::Request.new(ip_as_s, sender, helo_domain, options)
      req.authenticate
    end
  end
end
