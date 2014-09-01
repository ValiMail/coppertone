require 'resolv'

class Resolv
  class DNS
    class Resource
      module IN
        # DNS record type for SPF records
        class SPF < Resolv::DNS::Resource::IN::TXT
          # resolv.rb doesn't define an SPF resource type.
          TypeValue = 99 # rubocop:disable Style/ConstantName
        end
      end
    end
  end
end
