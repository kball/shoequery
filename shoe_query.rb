class String
  #camelize copied from activesupport
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self.first + camelize(self)[1..-1]
    end
  end

end
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
      Shoes.const_get(klass.to_s.camelize)
    end
  end

  def method_missing(method, *args)
    if args.empty?
      # if you have no arguments, think of it as a query and return the answer
      # for the first element.
      if first.respond_to? method
        return first.send(method)
      else
        return elem.style(method)
      end
    else
      # Otherwise, think of it as a setter
      setter = "#{method}=".to_sym
      if first.respond_to? setter
        each {|elem| elem.send(setter, *args)}
      else
        each {|elem| elem.style(method => args[0])}
      end
    end
    self
  end
end

class Shoes::App
  def shoe_query(stuff)
    ShoeQuery.new(self.slot, stuff)
  end
end
