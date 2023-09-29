# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 sampler application core extensions
###

class ::String

  def modulize!
    self.gsub!(/[^a-zA-Z0-9_]/, '_')
    self.sub!(/^[a-z\d]*/) { $&.capitalize }
    self.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    self
  end

  def modulize
    self.dup.modulize!
  end
end

# Hack to make the sample loader modules behave like the normal 'toplevel' binding
# otherwise samples using 'include Wx' (or other modules) will fail on referencing
# a constant unscoped from one of these included modules
class ::Module
  def const_missing(sym)
    if self.name.start_with?('WxRuby::Sample::SampleLoader_') && (scope = self.name.split('::')).size > 3
      top_mod = Object.const_get(scope[0,3].join('::'))
      return top_mod.const_get(sym)
    end
    begin
      super
    rescue NoMethodError
      raise NameError, "uninitialized constant #{sym}"
    end
  end
end

# Hack to make the sample loader modules behave like the normal 'toplevel' binding
# otherwise samples using 'include Wx' (or other modules) will fail on referencing
# a (module) method unscoped from one of these included modules
module ::Kernel
  def method_missing(name, *args, &block)
    if self.class.name.start_with?('WxRuby::Sample::SampleLoader_') && (scope = self.class.name.split('::')).size > 3
      top_mod = Object.const_get(scope[0,3].join('::'))
      return top_mod.__send__(name, *args, &block) if top_mod.respond_to?(name)
      top_mod.included_modules.each do |imod|
        return imod.__send__(name, *args, &block) if imod.respond_to?(name)
      end
    end
    super
  end
end
