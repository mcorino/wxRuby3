# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class XmlNode < Director

      def setup
        super
        spec.disable_proxies
        spec.gc_as_untracked
        spec.disown 'wxXmlNode *child'
        # ignore this; only allow adding child node by explicitly calling Add/Insert-child methods (easier on the GC handling and avoids wxXmlAttribute)
        spec.ignore 'wxXmlNode::wxXmlNode(wxXmlNode *, wxXmlNodeType, const wxString &, const wxString &, wxXmlAttribute *, wxXmlNode *, int)'
        # avoid wxXmlAttribute
        spec.ignore 'wxXmlNode::GetAttributes() const' # add alternative returning list of names
        spec.ignore 'wxXmlNode::AddAttribute(wxXmlAttribute *)'
        spec.ignore 'wxXmlNode::SetAttributes(wxXmlAttribute *)'
        spec.ignore 'wxXmlNode::GetAttribute(const wxString &, wxString *) const' # implement pure Ruby alternative
        # ignore these, we want wxXmlNode mostly (only?) to be able to inspect custom nodes from an XmlResource
        # NOT to manipulate any nodes
        spec.ignore('wxXmlNode::SetChildren(wxXmlNode *)')
        spec.ignore('wxXmlNode::SetParent(wxXmlNode *)')
        spec.ignore('wxXmlNode::SetNext(wxXmlNode *)')
        spec.ignore('wxXmlNode::RemoveChild(wxXmlNode *)')
        spec.add_extend_code 'wxXmlNode', <<~__HEREDOC
          VALUE GetAttributes()
          {
            VALUE result = rb_ary_new();
            wxXmlAttribute* attptr = self->GetAttributes();
            while (attptr)
            {
              rb_ary_push(result, WXSTR_TO_RSTR(attptr->GetName()));
              attptr = attptr->GetNext();
            }
            return result;
          }
          __HEREDOC
      end
    end # class XmlNode

  end # class Director

end # module WXRuby3
