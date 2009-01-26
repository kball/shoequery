class ShoeQuery < Array
  def initialize(base, stuff)
    if stuff.is_a? String
      super(self.class.find(base, stuff))
    else
      super([stuff].flatten)
    end
  end

  def find(descriptor)
    map do |elem|
      self.class.find(elem, descriptor)
    end.flatten.compact.uniq  
  end
  def self.find(base, descriptor)
    # for now only support individual types such as para, or button
    if descriptor.is_a? String  # deal with nested case
      chain = descriptor.split
      if chain.size > 1
        return self.find(base, chain[0]).find(chain[1..-1].join(' '))
      end
    end

    k = get_class(descriptor)
    return [] unless (base && k && k.is_a?(Class))
    results = base.is_a?(k) ? [base] : []
    if base.respond_to? :children
      results += base.children.map {|child| self.find(child, k) }.flatten.compact
    end
    ShoeQuery.new(base, results)
  end

  def self.get_class(klass)
    if klass.is_a? Class
      klass
    else
      Shoes.const_get(klass.to_s.capitalize)
    end
  end
end

class Shoes::App
  def shoe_query(stuff)
    ShoeQuery.new(self.slot, stuff)
  end
end
