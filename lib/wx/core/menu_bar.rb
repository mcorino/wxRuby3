
class Wx::MenuBar

  alias :wx_initialize :initialize

  def initialize(*args, &block)
    wx_initialize(*args)
    if block
      if block.arity == -1 or block.arity == 0
        self.instance_eval(&block)
      elsif block.arity == 1
        block.call(self)
      else
        Kernel.raise ArgumentError,
                     "Block to initialize should accept a single argument or none"
      end
    end
  end

end
