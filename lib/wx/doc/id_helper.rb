# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Mixin module to provide convenience method for defining Windows/Control ids.
  # @example Define an ID module
  #   module MyIDS
  #     include Wx::IDHelper
  #     # by default the offset for the next id is Wx::ID_HIGHEST which makes 'Wx::ID_HIGHEST+1'
  #     # the first id value returned.
  #     MY_FIRST_ID = self.next_id
  #     MY_SECOND_ID = self.next_id   # MY_SECOND_ID will have value Wx::ID_HIGHEST+2
  #
  #     # optionally a user defined offset can be specified like this:
  #     MY_OTHER_ID = self.next_id(MY_FIRST_ID+1000)  # MY_OTHER_ID will have value MY_FIRST_ID+1001
  #     MY_OTHER_ID2 = self.next_id                   # MY_OTHER_ID2 will have value MY_FIRST_ID+1002
  #   end
  #
  module IDHelper

    # Provides the singleton method #next_id to the including module.
    def self.included(base) end

  end

end
