module Authy
	module E164Adapter
		module HashAttributeAdapter
			def adapt!
        self[:country_code] ||= Phony.split(self[:cellphone].gsub(/\+/, '')).first
			end
		end
	end
end
