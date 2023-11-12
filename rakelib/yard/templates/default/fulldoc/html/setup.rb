# frozen_string_literal: true

def init
  # It seems YARD messes things up so that a number of classes are not properly
  # registered in their enclosing namespaces.
  # This hack makes sure that if that is the case we fix that here.
  all_classes = Registry.all(:class)
  all_classes.each do |c|
    if (ns = c.namespace)
      unless ns.children.any? { |nsc| nsc.path == c.path }
        ns.children << c # class missing from child list of enclosing namespace -> add here
      end
    end
    if (ns = Registry[c.namespace.path])
      unless ns.children.any? { |nsc| nsc.path == c.path }
        ns.children << c # class missing from child list of enclosing namespace -> add here
      end
    end
  end
  super
end

def stylesheets_full_list
  super + %w(css/wxruby3.css)
end

def logo_and_version
  wxver = Registry['Wx::WXRUBY_VERSION']
  wxwver = Registry['Wx::WXWIDGETS_VERSION']
  <<~__HTML
  <div class='wxrb-logo'>
    <img src='assets/logo.png' height='38'/>
    <table><tbody>
      <tr><td><span class='wxrb-name'><a href="https://github.com/mcorino/wxRuby3">wxRuby3</a></span></td><td><span class='wxrb-version'>Version: #{::Kernel.eval(wxver.value)}</span></td></tr>
      <tr><td></td><td><span class="wxrb-wxver">(wxWidgets: #{::Kernel.eval(wxwver.value)})</span></td></tr>
    </tbody></table>
  </div>
  __HTML
end
