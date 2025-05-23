# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# WxRuby Extensions - Dialog functors for wxRuby3

class Wx::Dialog

  class << self

    wx_set_layout_adapter = instance_method :set_layout_adapter
    wx_redefine_method :set_layout_adapter do |adapter|
      prev_adapter = wx_set_layout_adapter.bind(self).call(adapter)
      @adapter = adapter # cache here to prevent premature GC collection
      prev_adapter
    end

  end

  def create_button_sizer(flags)
    if Wx.has_feature?(:USE_BUTTON)
      create_std_dialog_button_sizer(flags)
    else
      nil
    end
  end

  def create_separated_sizer(sizer)
    # Mac Human Interface Guidelines recommend not to use static lines as
    # grouping elements
    if Wx.has_feature?(:USE_STATLINE) && Wx::PLATFORM != 'WXOSX'
      topsizer = Wx::VBoxSizer.new
      topsizer.add(Wx::StaticLine.new(self),
                   Wx::SizerFlags.new.expand.double_border(Wx::BOTTOM))
      topsizer.add(sizer, Wx::SizerFlags.new.expand)
      sizer = topsizer
    end

    sizer
  end

  def create_separated_button_sizer(flags)
      sizer = create_button_sizer(flags)
      return create_separated_sizer(sizer) if sizer
      nil
  end

  module Functor
    def self.included(klass)
      scope = klass.name.split('::')
      functor_nm = scope.pop
      code = <<~__CODE
        def #{functor_nm}(*args, **kwargs, &block)
          dlg = kwargs.empty? ? #{klass.name}.new(*args) : #{klass.name}.new(*args, **kwargs)
          begin
            if block_given?
              return block.call(dlg)
            else
              return dlg.show_modal
            end
          rescue Exception
            Wx.log_debug "\#{$!}\\n\#{$!.backtrace.join("\\n")}"
            raise
          ensure
            dlg.destroy
          end
        end
        __CODE
      if scope.empty?
        ::Kernel.module_eval code
      else
        scope.inject(::Object) { |mod, nm| mod.const_get(nm) }.singleton_class.module_eval code
      end
      klass.class_eval do
        def self.inherited(sub)
          sub.include Wx::Dialog::Functor
        end
      end unless klass.singleton_class.method_defined?(:inherited)
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
