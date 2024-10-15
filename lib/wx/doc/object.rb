# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Object

    # By default Wx:::Object derived classes cannot be #dup-licated.
    # Some derived classes (like GDIObject-s) may provide functional overloads.
    # @return [nil]
    def dup; end

    # By default Wx::Object derived class instances cannot be cloned but instead return self.
    # Derived classes (like the Event classes) may provide functional overloads.
    # @return [self]
    def clone; end

  end

end
