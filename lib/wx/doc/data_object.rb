
module Wx

  class DataObject

    # Returns the data size of the given format.
    # Should be overridden in derived classes.
    # @note **IMPORTANT** Please note that it is necessary to return the **size in bytes** of the data string
    # returned by #get_data_here (not the size in characters).
    # @param format [Wx::DataFormat]
    # @return [Integer]
    def get_data_size(format) end
    alias_method :data_size, :get_data_size

  end

  # This is an (abstract in Ruby) base class for the simplest possible custom data objects.
  # Unlike in C++ in Ruby this class cannot be used to derive custom data objects from but
  # instead {Wx::DataObjectSimpleBase} (derived from Wx::DataObjectSimple) should be used.
  # The data object of (a class derived from) this class only supports <b>one format</b>,
  # so the number of virtual functions to be implemented is reduced.
  # This class is the base class for {Wx::TextDataObject}, {Wx::FileDataObject}, {Wx::BitmapDataObject},
  # {Wx::wxCustomDataObject} and others.
  # ===
  #
  # Category:  Clipboard and Drag & Drop
  # @see Drag and Drop Overview
  # @see  Drag & Drop Sample
  class DataObjectSimple < DataObject

    # @overload get_data_size(format)
    #   Returns the data size of the format for this object.
    #   @param [Wx::DataFormat] format ignored for this class
    #   @return [Integer] default always returns 0
    # @overload get_data_size()
    #   Returns the data size of the format for this object.
    #   @return [Integer] default always returns 0
    def get_data_size(*) end

    # @overload get_data_here(format)
    #   Returns the data of this object.
    #   @param [Wx::DataFormat] format ignored for this class
    #   @return [String,nil] data of this object
    # @overload get_data_here()
    #   Returns the data of this object.
    #   @return [String,nil] data of this object
    def get_data_here(*) end

    # @overload set_data(format, buf)
    #   Sets the data for this object and returns true if successful, false otherwise.
    #   @param [Wx::DataFormat] format ignored for this class
    #   @param [String] buf non-nil data
    #   @return [Boolean] default always returns false.
    # @overload set_data(buf)
    #   Sets the data for this object and returns true if successful, false otherwise.
    #   @param [String] buf non-nil data
    #   @return [Boolean] default always returns false.
    def set_data(*) end

  end

  # This is the base class for the simplest possible custom data objects.
  # The data object of (a class derived from) this class only supports <b>one format</b>,
  # so the number of methods to be implemented is reduced.
  # To be useful it must be derived. Derived objects supporting rendering the data must
  # override {Wx::DataObjectSimpleBase#_get_data_size} and {Wx::DataObjectSimpleBase#_get_data}.
  # By default these methods respectively return <code>0</code> and <code>nil</code>.
  # The objects which may be set must override {Wx::DataObjectSimpleBase#_set_data} (which
  # returns <code>false</code>).
  # Of course, the objects supporting both operations must override all three methods.
  # ===
  #
  # Category:  Clipboard and Drag & Drop
  # @see Drag and Drop Overview
  # @see  Drag & Drop Sample
  # @see  Wx::DataObjectSimple
  class DataObjectSimpleBase < DataObjectSimple

    # Returns this object's data size.
    # The default implementation calls #_get_data and determines the size of the returned data string (if any).
    # As this is not very optimal for more complex (and larger data objects) very often this method will be
    # overridden in derived classes.
    # @note **IMPORTANT** Please note that it is necessary to return the **size in bytes** of the data string
    # returned by #_get_data (not the size in characters).
    # @return [Integer]
    def _get_data_size; end
    protected :_get_data_size

    # Returns this object's data (default implementation returns nil).
    # Should be overridden in derived classes.
    # @return [String,nil]
    def _get_data; end
    protected :_get_data

    # Sets this object's data (default implementation does nothing and returns false).
    # Should be overridden in derived classes.
    # @param [String] buf non-nil data
    # @return [Boolean]
    def _set_data(buf); end
    protected :_set_data

  end

end
