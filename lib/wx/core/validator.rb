
class Wx::Validator
  # Default implementation of clone, may need to be over-ridden if
  # custom subclasses should state variables that need to be copied
  def clone
    self.class.new
  end
end
