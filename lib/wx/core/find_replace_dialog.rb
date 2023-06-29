
module Wx

  class FindReplaceDialog < Wx::Dialog

    # add caching for FindReplaceData object
    # dialog does not take over ownership but does allow referencing
    # the data object so we need to keep it alive here

    wx_initialize = instance_method :initialize
    define_method :initialize do |parent, data, *args|
      wx_initialize.bind(self).call(parent, data, *args)
      @fr_data = data
    end

    wx_set_data = instance_method :set_data
    define_method :set_data do |data|
      wx_set_data.bind(self).call(data)
      @fr_data = data
    end

  end

end
