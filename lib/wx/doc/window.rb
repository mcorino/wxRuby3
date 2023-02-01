# Additional event handler methods documentation stubs.


class Wx::Window

  # Ruby wrapper for the C++ OnInternalIdle method.
  # To override this method create an #on_internal_idle (**NOT** #wx_on_internal_idle) method in Ruby which will be called
  # instead of the original C++ method. The original can be called from this override (instead of calling 'super')
  # by calling #wx_on_internal_idle.
  def wx_on_internal_idle; end

end
