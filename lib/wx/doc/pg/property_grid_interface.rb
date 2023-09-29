# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx::PG

  class PropertyGridInterface

    # When a block is given iterates properties as specified passing
    # each property to the block.
    # Returns an enumerator when no block is given.
    # The start position defaults to Wx::TOP for forward iteration and Wx::BOTTOM for reverse iteration.
    # @overload each_property(flags, start, reverse: , &block)
    #   @param flags [Integer] flags specifying iteration (see {Wx::PG::PG_ITERATOR_FLAGS})
    #   @param start [Integer,Wx::PG::Property] start position (either {Wx::Direction::TOP} or {Wx::Direction::BOTTOM} or the property to start at)
    #   @param reverse [true,false] iterate properties in reverse
    #   @yieldparam item [Wx::PG::PGProperty] property
    #   @return [Object] result of last block execution
    # @overload each_property(flags, start, reverse:)
    #   @param flags [Integer] flags specifying iteration (see {Wx::PG::PG_ITERATOR_FLAGS})
    #   @param start [Integer,Wx::PG::Property] start position (either {Wx::Direction::TOP} or {Wx::Direction::BOTTOM} or the property to start at)
    #   @param reverse [true,false] iterate properties in reverse
    #   @return [Enumerator] an enumerator
    def each_property(flags = Wx::PG::PG_ITERATE_DEFAULT, start = nil, reverse: false, &block) end
    alias :properties :each_property

    # Convenience method to perform reverse iteration.
    # Calls #each_property with <code>reverse: true</code>.
    # The start position defaults to Wx::BOTTOM.
    # @overload reverse_each_property(flags, start, &block)
    #   @param flags [Integer] flags specifying iteration (see {Wx::PG::PG_ITERATOR_FLAGS})
    #   @param start [Integer,Wx::PG::Property] start position (either {Wx::Direction::TOP} or {Wx::Direction::BOTTOM} or the property to start at)
    #   @param reverse [true,false] iterate properties in reverse
    #   @yieldparam item [Wx::PG::PGProperty] property
    #   @return [Object] result of last block execution
    # @overload reverse_each_property(flags, start)
    #   @param flags [Integer] flags specifying iteration (see {Wx::PG::PG_ITERATOR_FLAGS})
    #   @param start [Integer,Wx::PG::Property] start position (either {Wx::Direction::TOP} or {Wx::Direction::BOTTOM} or the property to start at)
    #   @param reverse [true,false] iterate properties in reverse
    #   @return [Enumerator] an enumerator
    def reverse_each_property(flags = Wx::PG::PG_ITERATE_DEFAULT, start = nil, &block) end
    alias :properties_reversed :reverse_each_property

    # When a block is given iterates all attributes of the specified property passing
    # each attribute variant to the block.
    # Returns an enumerator when no block is given.
    # @overload each_property_attribute(id , &block)
    #   @param id [String,Wx::PG::PGProperty] (name of) property to iterate attributes of
    #   @yieldparam item [Wx::Variant] attribute
    #   @return [Object] result of last block execution
    # @overload each_property_attribute(id)
    #   @param id [String,Wx::PG::PGProperty] (name of) property to iterate attributes of
    #   @return [Enumerator] an enumerator
    def each_property_attribute; end
    alias :property_attributes :each_property_attribute

    # Returns the current grid state.
    # Depending on the actual grid object (Wx::PropertyGrid or Wx::PropertyGridManager)
    # this will return either a Wx::PG::PropertyGridPageState instance or a
    # Wx::PG::PropertyGridPage instance (current page of Wx::PropertyGridManager).
    # Both provide the same interface (Ruby duck typing applies here).
    # @return [Wx::PG::PropertyGridPage,Wx::PG::PropertyGridPageState]
    def get_state; end
    alias :state :get_state
  end

end
