#--------------------------------------------------------------------
# @file    grid_table_base.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class GridTableBase < Director

      def setup
        super
        spec.ignore %w[
          wxGridTableBase::CanHaveAttributes
          wxGridTableBase::GetAttrProvider
          wxGridTableBase::SetAttrProvider
          wxGridTableBase::GetAttrPtr]
        spec.add_swig_code <<~__HEREDOC
          %typemap(directorin) wxGridCellAttr::wxAttrKind "$input = INT2NUM($1);"
          __HEREDOC
        # wxWidgets takes over managing the ref count
        spec.disown('wxGridCellAttr* attr')
        # this requires wxRuby to take ownership (ref counted)
        spec.new_object 'wxGridTableBase::GetAttr'
        # these warnings are handled and can be suppressed
        spec.suppress_warning(473,
                              'wxGridTableBase::GetAttr',
                              'wxGridTableBase::GetView')
      end
    end # class GridTableBase

  end # class Director

end # module WXRuby3
