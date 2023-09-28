# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module ItemContainerTests

  def test_ic_append
    container.append("item 0")

    assert_equal("item 0", container.get_string(0))

    container.append(['item 1', 'item 2'])

    assert_equal("item 1", container.get_string(1))
    assert_equal("item 2", container.get_string(2))

    container.append(['item 3', 'item 4'])

    assert_equal("item 3", container.get_string(3))
    assert_equal("item 4", container.get_string(4))
  end

  def test_ic_insert
    assert_equal(0, container.insert("item 0", 0))
    assert_equal("item 0", container.get_string(0))

    assert_equal(1, container.insert(['item 1', 'item 2'], 0))

    assert_equal("item 1", container.get_string(0))
    assert_equal("item 2", container.get_string(1))

    assert_equal(2, container.insert(['item 3', 'item 4'], 1))
    assert_equal("item 3", container.get_string(1))
    assert_equal("item 4", container.get_string(2))
  end
  
  def test_ic_count
    assert(container.empty?)
    assert_with_assertion_failure { container.get_string(0) }

    container.append(['item 0', 'item 1', 'item 2', 'item 3'])

    assert(!container.empty?)
    assert_equal(4, container.count)

    container.delete(0)

    assert_equal(3, container.count)

    container.delete(0)
    container.delete(0)

    assert_equal(1, container.count)

    container.insert(['item 0', 'item 1', 'item 2', 'item 3'], 1)

    assert_equal(5, container.count)
    assert_with_assertion_failure { container.get_string(10) }
  end

  def test_ic_item_selection
    container.append(['item 0', 'item 1', 'item 2', 'ITEM 2'])

    container.set_selection(Wx::NOT_FOUND)
    assert_equal(Wx::NOT_FOUND, container.get_selection)
    assert_equal("", container.get_string_selection)

    container.set_selection(1)
    assert_equal(1, container.get_selection)
    assert_equal("item 1", container.get_string_selection)

    assert(container.set_string_selection("item 2"))
    assert_equal(2, container.get_selection)
    assert_equal("item 2", container.get_string_selection)

    # Check that selecting a non-existent item fails.
    assert(!container.set_string_selection("bloordyblop"))

    # Check that SetStringSelection() is case-insensitive.
    assert(container.set_string_selection("ITEM 2"))
    assert_equal(2, container.get_selection)
    assert_equal("item 2", container.get_string_selection)
  end
    
end
