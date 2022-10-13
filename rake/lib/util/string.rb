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

      RBKW = %w[
          __FILE__ and def end in or self unless __LINE__ begin defined? ensure module redo
          super until BEGIN break do false next rescue then when END case else for retry true while
          alias class elsif if not return undef
      ]

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
        rbnm.sub!(/\Aoperator/, '')
        rbnm << '_' if RBKW.include?(rbnm)
        rbnm
      end

      def rb_param_name(name)
        rbnm = name.dup
        rbnm << '_' if RBKW.include?(name)
        rbnm
      end

      def rb_wx_name(name)
        name.sub(/\Awx/i, '')
      end

      def rb_module_name(name)
        rb_wx_name(name).sub(/\A[a-z]/) { |s| s.upcase }
      end

      def rb_constant_value(name)
        val = rb_wx_name(name)
        val == 'NULL' ? 'nil' : val
      end

    end

  end

end
