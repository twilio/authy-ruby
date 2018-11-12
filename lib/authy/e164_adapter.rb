module Authy
	module E164Adapter
		module HashAttributeAdapter
			def adapt!
				split = Phony.split(self[:cellphone].gsub(/\+/, ''))
        self[:country_code] = split.first
			end
		end
	end
end
