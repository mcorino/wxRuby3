###
# String utilities mixin
# Copyright (c) M.J.N. Corino, The Netherlands
###

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
        s.gsub!(/([a-z])([A-Z])/,"\\1_\\2")
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
        rbnm.sub!(/\A_wx_/, 'wx_')
        rbnm.sub!(/\Aoperator/, '')
        rbnm << '_' if RBKW.include?(rbnm)
        rbnm
      end

      def rb_constant_name(name)
        rbnm = underscore(name)
        rbnm.sub!(/\Awx_/, '')
        rbnm.upcase!
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
        val = name.sub(/\Awx/, 'Wx::')
        val == 'NULL' ? 'nil' : val
      end

      def rb_constant_expression(exp)
        exp.gsub(/(\w+(::\w+)*)(\s*\()?/) do |s|
          idstr = $1
          is_call = !!$3
          is_scoped = false
          ids = idstr.split('::')
          if ids.size > 1
            is_scoped = true
            scoped_name = rb_constant_value(ids.shift)
            while ids.size > 1
              scoped_name << '::' << ids.shift
            end
          end
          idstr = ids.shift
          if is_call
            # object ctor or static method call
            if is_scoped
              # static method
              "#{scoped_name}.#{rb_method_name(idstr)}("
            else
              # ctor
              case idstr
              when 'wxString'
                '('
              else
                "#{rb_constant_value(idstr)}.new("
              end
            end
          else
            if is_scoped
              # nested identifier
              "#{scoped_name}::#{idstr}"
            else
              # constant
              if /[\-\+\.\d]+/ =~ idstr
                idstr # numeric constant
              elsif /\A(true|false|NULL)/ =~ idstr
                $1 == 'NULL' ? 'nil' : $1
              else
                "Wx::#{rb_constant_name(idstr)}"
              end
            end
          end
        end
      end

    end

  end

end
