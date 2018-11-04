class Hash(K, V)
  def dig?(key : K, *subkeys)
    if (value = self[key]?) && value.responds_to?(:dig?)
      value.dig?(*subkeys)
    end
  end

  # :nodoc:
  def dig?(key : K)
    self[key]?
  end

  def dig(key : K, *subkeys)
    if (value = self[key]) && value.responds_to?(:dig)
      return value.dig(*subkeys)
    end
    raise KeyError.new "Hash value not diggable for key: #{key.inspect}"
  end

  # :nodoc:
  def dig(key : K)
    self[key]
  end
end
