#--------------------------------------------------------------------
# @file    string.rb
# @author  Martin Corino
#
# @brief   String utilities mixin
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  module Util

    module StringUtil

      def simple_underscore!(s)
        s.gsub!(/([A-Z])/, '_\1')
        s.downcase!
        s
      end

      def simple_underscore(s)
        underscore!(s.dup)
      end

      def underscore(s)
        underscore!(s.dup)
      end

      def underscore!(s)
        s.gsub!(/::/, '/')
        s.gsub!(/([A-Z]+)([A-Z][a-z])/,"\\1_\\2")
        s.gsub!(/([a-z\d])([A-Z])/,"\\1_\\2")
        s.tr('-','_')
        s.downcase!
        s
      end

      def rb_class_name(name)
        name.sub(/\Awx_?/i, '')
      end

      def rb_method_name(name)
        rbnm = underscore(name)
        rbnm.sub!(/\Awx_/, '')
        rbnm
      end

      def rb_constant_name(name)
        name.sub(/\Awx/i, '')
      end

    end

  end

end
