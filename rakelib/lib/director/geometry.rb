# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Geometry < Director

      def setup
        spec.items.replace %w{wxPoint2DInt wxPoint2DDouble}

        spec.ignore 'wxPoint2DInt::m_x', 'wxPoint2DInt::m_y',
                    'wxPoint2DDouble::m_x', 'wxPoint2DDouble::m_y'

        spec.add_extend_code 'wxPoint2DInt', <<~__HEREDOC
          wxInt32 get_x()
          {
            return $self->m_x;
          }
          wxInt32 set_x(wxInt32 v)
          {
            return ($self->m_x = v);
          }
          wxInt32 get_y()
          {
            return $self->m_y;
          }
          wxInt32 set_y(wxInt32 v)
          {
            return ($self->m_y = v);
          }
          void assign(const wxPoint2DInt& pt)
          {
            (*$self) = pt;
          }
          void add(const wxPoint2DInt& pt)
          {
            (*$self) += pt;
          }
          void sub(const wxPoint2DInt& pt)
          {
            (*$self) -= pt;
          }
          void mul(const wxPoint2DInt& pt)
          {
            (*$self) *= pt;
          }
          void mul(wxDouble v)
          {
            $self->m_x *= v; $self->m_y *= v;
          }
          void mul(wxInt32 v)
          {
            $self->m_x *= v; $self->m_y *= v;
          }
          void div(const wxPoint2DInt& pt)
          {
            (*$self) /= pt;
          }
          void div(wxDouble v)
          {
            $self->m_x /= v; $self->m_y /= v;
          }
          void div(wxInt32 v)
          {
            $self->m_x /= v; $self->m_y /= v;
          }
          __HEREDOC

        spec.add_extend_code 'wxPoint2DDouble', <<~__HEREDOC
          wxDouble get_x()
          {
            return $self->m_x;
          }
          wxDouble set_x(wxDouble v)
          {
            return ($self->m_x = v);
          }
          wxDouble get_y()
          {
            return $self->m_y;
          }
          wxDouble set_y(wxDouble v)
          {
            return ($self->m_y = v);
          }
          void assign(const wxPoint2DDouble& pt)
          {
            (*$self) = pt;
          }
          void add(const wxPoint2DDouble& pt)
          {
            (*$self) += pt;
          }
          void sub(const wxPoint2DDouble& pt)
          {
            (*$self) -= pt;
          }
          void mul(const wxPoint2DDouble& pt)
          {
            (*$self) *= pt;
          }
          void mul(wxDouble v)
          {
            $self->m_x *= v; $self->m_y *= v;
          }
          void mul(wxInt32 v)
          {
            $self->m_x *= v; $self->m_y *= v;
          }
          void div(const wxPoint2DDouble& pt)
          {
            (*$self) /= pt;
          }
          void div(wxDouble v)
          {
            $self->m_x /= v; $self->m_y /= v;
          }
          void div(wxInt32 v)
          {
            $self->m_x /= v; $self->m_y /= v;
          }
          __HEREDOC

        spec.map_apply 'int * OUTPUT' => 'wxInt32 *'

        # ignore all friend operators
        spec.do_not_generate :functions

      end

    end

  end

end
