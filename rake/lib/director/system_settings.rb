#--------------------------------------------------------------------
# @file    system_settings.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class SystemSettings < Director

      def setup
        spec.gc_as_object
        spec.ignore 'wxSystemSettings::GetAppearance'
        spec.add_swig_code <<~__HEREDOC
          %typemap(in) wxSystemColour "$1 = (wxSystemColour)NUM2INT($input);"
          %typemap(out) wxSystemColour " $result = INT2NUM((int)$1);"
          %typemap(in) wxSystemFont "$1 = (wxSystemFont)NUM2INT($input);"
          %typemap(out) wxSystemFont "$result = INT2NUM((int)$1);"
          %typemap(in) wxSystemMetric "$1 = (wxSystemMetric)NUM2INT($input);"
          %typemap(out) wxSystemMetric "$result = INT2NUM((int)$1);"
        __HEREDOC
        super
      end
    end # class SystemSettings

  end # class Director

end # module WXRuby3
