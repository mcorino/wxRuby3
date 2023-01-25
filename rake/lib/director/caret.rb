###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Caret < Director

      def setup
        super
        spec.gc_as_object 'wxCaret'
        # ignore method overloads that have no additional benefit  in Ruby
        spec.ignore 'wxCaret::wxCaret(wxWindow*, int, int)',
                    'wxCaret::Create(wxWindow*, int, int)',
                    'wxCaret::GetPosition(int*, int*) const',
                    'wxCaret::GetSize(int*, int*) const',
                    'wxCaret::Move(int, int)',
                    'wxCaret::SetSize(int, int)'
        # prevent SWIG warning
        spec.extend_interface 'wxCaret', 'virtual ~wxCaret();'
      end
    end # class Caret

  end # class Director

end # module WXRuby3
