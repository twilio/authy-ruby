module Authy
	module E164Adapter
		def self.adapt attributes
			if attributes[:country_code].nil?
        split = Phony.split(attributes[:cellphone].gsub(/\+/, ''))
        attributes[:country_code] = split.first
      end

      attributes
		end
	end
end
