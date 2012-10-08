class Array
  def self.diff(one, other)
    one.zip(other).each do |ones, others|
      return 0 if ones.nil? && others.nil?
      
      return -1 if ones.nil?
      return 1 if others.nil?
      
      return -1 if ones < others
      return 1 if others < ones
    end
    
    return 0
  end

  def < (other);  Array.diff(self, other) < 0; end
  def > (other);  Array.diff(self, other) > 0; end
  def <= (other); Array.diff(self, other) <= 0; end
  def >= (other); Array.diff(self, other) >= 0; end
end

class Hash
  def deep_merge(other_hash)
    self.merge(other_hash) do |key, oldval, newval|
      oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
      newval = newval.to_hash if newval.respond_to?(:to_hash)
      oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? oldval.deep_merge(newval) : newval
    end
  end
end
