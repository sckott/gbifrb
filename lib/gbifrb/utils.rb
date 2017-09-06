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

def check_data(x, y)
  if len2(x) == 1
    testdata = [x]
  else
    testdata = x
  end

  for z in testdata
    if !y.include? z
      raise z + ' is not one of the choices'
    end
  end
end

def len2(x)
  if x.class == String
    return [x].length
  else
    return x.length
  end
end

def stop(x)
  raise ArgumentError, x
end

# def get_meta(x)
#   if has_meta(x)
#     return { z: x[z] for z in ['offset','limit','endOfRecords'] }
#   else
#     return nil
#   end
# end

# def has_meta(x)
#   if x.__class__ != dict
#     return false
#   else
#     tmp = [y in x.keys() for y in ['offset','limit','endOfRecords']]
#     return True in tmp
#   end
# end
