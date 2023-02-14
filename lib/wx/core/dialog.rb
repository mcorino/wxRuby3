
class Wx::Dialog

  module Functor
    def self.included(klass)
      scope = klass.name.split('::')
      functor_nm = scope.pop
      code = <<~__CODE
        def #{functor_nm}(*args, &block)
          dlg = #{klass.name}.new(*args)
          begin
            block.call(dlg) if block_given?
          ensure
            dlg.destroy
          end
        end
        __CODE
      unless scope.empty?
        scope.inject(::Object) { |mod, nm| mod.const_get(nm) }.singleton_class.module_eval code
      end
      klass.class_eval do
        def self.inherited(sub)
          sub.include Wx::Dialog::Functor
        end
      end
    end
  end

  include Functor

  def self.setup_dialog_functors(mod)
    # find all Dialog descendants in mod and setup the dialog Functor for them
    mod.constants.select do |c|
      ::Class === (const = mod.const_get(c)) && const < Wx::Dialog
    end.each { |c| mod.const_get(c).include Wx::Dialog::Functor }
  end

  setup_dialog_functors(Wx)
end
