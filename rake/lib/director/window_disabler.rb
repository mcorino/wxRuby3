#--------------------------------------------------------------------
# @file    window_disabler.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class WindowDisabler < Director

      def setup
        super
        spec.disable_proxies
        # scope delimited guard constructs do not work in Ruby
        # so we'll have to use a block approach to Rubify
        # remove ctor (essentially make this a namespace/module instead of class)
        spec.ignore 'wxWindowDisabler::wxWindowDisabler'
        # add Ruby-style static method
        spec.add_extend_code 'wxWindowDisabler', <<~__HEREDOC
          static void disable(wxWindow *to_skip = NULL)
          {
            if (rb_block_given_p())
            {
              wxWindowDisabler disabler(to_skip);
              rb_yield(Qnil);
            }
            return ;
          }
          __HEREDOC
        spec.ignore %w[
          wxFindWindowByLabel
          wxFindWindowByName
          wxNewId
          wxPostDelete
          wxUsleep
          ]
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class WindowDisabler

  end # class Director

end # module WXRuby3
