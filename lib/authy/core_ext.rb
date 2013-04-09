class Hash
  def self.try_convert(value)
    return value if value.instance_of?(Hash)
    return nil if !value.respond_to?(:to_hash)
    converted = value.to_hash
    return converted if converted.instance_of?(Hash)

    cname = value.class.name
    raise TypeError, "can't convert %s to %s (%s#%s gives %s)" %
      [cname, Hash.name, cname, :to_hash, converted.class.name]
  end unless Hash.respond_to?(:try_convert)
end

class Array
  def self.try_convert(value)
    return value if value.instance_of?(Array)
    return nil if !value.respond_to?(:to_ary)
    converted = value.to_ary
    return converted if converted.instance_of?(Array)

    cname = value.class.name
    raise TypeError, "can't convert %s to %s (%s#%s gives %s)" %
      [cname, Array.name, cname, :to_ary, converted.class.name]
  end unless Array.respond_to?(:try_convert)
end

