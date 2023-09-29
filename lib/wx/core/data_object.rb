# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  # Provide some default implementations of these to make life easier
  class DataObject
    def get_preferred_format(direction)
      get_all_formats(direction).first
    end

    def get_format_count(direction)
      get_all_formats(direction).size
    end
  end

  class DataObjectSimple

    # implement the overloads which do not require the format arg
    # using pure Ruby

    wx_get_data_size = instance_method :get_data_size
    define_method :get_data_size do |format = nil|
      wx_get_data_size.bind(self).call(format || self.get_format)
    end

    wx_get_data_here = instance_method :get_data_here
    define_method :get_data_here do |format = nil|
      wx_get_data_here.bind(self).call(format || self.get_format)
    end

    wx_set_data = instance_method :set_data
    define_method :set_data do |*args|
      if args.size>1
        format, buf = args
      else
        format = nil
        buf = args.first
      end
      wx_set_data.bind(self).call(format || self.get_format, buf)
    end

  end

  class DataObjectSimpleBase

    # implement these in pure Ruby for optimization
    def get_data_size(*)
      self._get_data_size
    end
    def get_data_here(*)
      self._get_data
    end

    def set_data(*args)
      if args.size>1
        _, buf = args
      else
        buf = args.first
      end
      self._set_data(buf)
    end

    def _get_data_size
      (_get_data || '').bytesize
    end
    protected :_get_data_size

  end

  class TextDataObject

    # override this to loose the extra terminating 0 we otherwise get
    def get_data_here(*)
      self.get_text
    end

  end

end
