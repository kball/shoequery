class String
  #camelize and demodulize copied from activesupport
  def camelize(first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self.first + camelize(self)[1..-1]
    end
  end
  def demodulize
   self.gsub(/^.*::/, '')
  end
end
class ShoeQuery < Array
  def initialize(base, stuff)
    @base = base
    if stuff.is_a? String
      super(self.class.find(base, stuff))
    else
      super([stuff].flatten)
    end
  end

  def find(descriptor = nil, &block)
    ShoeQuery.new(@base, self.map do |elem|
      self.class.find(elem, descriptor, &block)
    end.flatten.compact.uniq )
  end
  def self.find(base, descriptor = nil, &block)
    # for now only support individual types such as para, or button
    if descriptor.is_a? String  # deal with nested case
      chain = descriptor.split
      if chain.size > 1
        return self.find(base, chain[0]).find(chain[1..-1].join(' '))
      end
    end
    k = get_class(descriptor)

    # Return empty unless there are more to find
    if !base || !(k.is_a?(Class) || block_given?) || 
       !(Shoes.constants + ['Shoes']).include?(base.class.to_s.demodulize)
      return []
    end

    results = (!k || base.is_a?(k)) ? [base] : []
    if base.respond_to? :children
      results += base.children.map do |child|
        self.find(child, k, &block)
      end.flatten.compact
    end
    if block_given?
      results = results.select {|x| yield x}
    end
    ShoeQuery.new(base, results)
  end

  def self.get_class(klass)
    if !klass
      nil
    elsif klass.is_a? Class
      klass
    else
      Shoes.const_get(klass.to_s.camelize)
    end
  end

  def method_missing(method, *args, &block)
    if args.empty? && !block_given?
      # if you have no arguments and no block, think of it as a query
      # and return the answer for the first element.
      if first.respond_to? method
        return first.send(method)
      else
        return elem.style(method)
      end
    elsif block_given?
      each {|elem| elem.send(method, *args, &block)}
    else
      # Otherwise, think of it as a setter
      setter = "#{method}=".to_sym
      if first.respond_to? setter
        each {|elem| elem.send(setter, *args, &block)}
      else
        each {|elem| elem.style(method => args[0], &block)}
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
