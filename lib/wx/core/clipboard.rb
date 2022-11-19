class Wx::Clipboard
  class << self
    # This is provided internally by the SWIG interface file, but all
    # public access should be via Clipboard.open; see below
    private :get_global_clipboard

    # Class method to provide access to the clipboard within a ruby
    # block. Tests that the clipboard could be accessed, and ensures
    # that it is closed when the block is finished.
    def open
      clip = nil
      # Trying to access the segfault outside main_loop will segfault on
      # some platforms (eg, GTK)
      unless Wx::const_defined?(:THE_APP)
        raise RuntimeError, 
              "The clipboard can only be accessed when the App is running"
      end

      clip = get_global_clipboard
      unless clip.open
        Kernel.raise "Could not open clipboard"
      end
      yield clip
     ensure
       clip.close if clip
    end
  end

  # Need to do some internal record-keeping to protect data objects on
  # the clipboard from garbage collection
  @@__clip_data = []

  # These methods affect the clipboard contents; each time, update the
  # record with the changed data contents
  wx_add_data = instance_method(:add_data)
  define_method(:add_data) do | the_data |
    @@__clip_data << the_data
    wx_add_data.bind(self).call(the_data)
  end

  wx_clear = instance_method(:clear)
  define_method(:clear) do 
    @@__clip_data.clear
    wx_clear.bind(self).call
  end

  wx_set_data = instance_method(:set_data)
  define_method(:set_data) do | the_data |
    @@__clip_data = [ the_data ]
    wx_set_data.bind(self).call(the_data)
  end

  # Aliases, more clearly expressive?
  alias :place :set_data
  alias :fetch :get_data
end
