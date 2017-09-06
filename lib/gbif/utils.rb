def make_ua
	requa = 'Faraday/v' + Faraday::VERSION
  habua = 'Gbif/v' + Gbif::VERSION
  return requa + ' ' + habua
end

class Hash
	def tostrings
		Hash[self.map{|(k,v)| [k.to_s,v]}]
	end
end

class Hash
	def tosymbols
		Hash[self.map{|(k,v)| [k.to_sym,v]}]
	end
end
