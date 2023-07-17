
require_relative './lib/wxframe_runner'

class BoxSizerTests < WxRuby::Test::GUITests

  def setup
    super
    @win = Wx::Window.new(test_frame, Wx::ID_ANY)
    @sizer = Wx::HBoxSizer.new
    @win.set_client_size(127, 35)
    @win.sizer = @sizer
  end

  def cleanup
    test_frame.destroy_children
    @win = nil
    @sizer = nil
  end

  attr_reader :win, :sizer

  def test_size
    sizeTotal = win.get_client_size
    sizeChild = sizeTotal / 2

    child = Wx::Window.new(win, Wx::ID_ANY, Wx::DEFAULT_POSITION, sizeChild)
    sizer.add(child)
    win.layout
    assert(child.size == sizeChild)

    sizer.clear
    sizer.add(child, Wx::SizerFlags.new(1))
    win.layout
    assert(child.size == [sizeTotal.x, sizeChild.y])

    sizer.clear
    sizer.add(child, Wx::SizerFlags.new(1).expand)
    win.layout
    assert(child.size == sizeTotal)

    sizer.clear
    sizer.add(child, Wx::SizerFlags.new)
    sizer.set_item_min_size(child, sizeTotal*2)
    win.layout
    assert(child.size == sizeTotal)

    sizer.clear
    sizer.add(child, Wx::SizerFlags.new.expand)
    sizer.set_item_min_size(child, sizeTotal*2)
    win.layout
    assert(child.size == sizeTotal)
  end

  class << self

    def _ltd(*args)
      @ltd_klass ||= Struct.new(:prop, :minsize, :x, :sizes, :dont_permute) do
        def add_to_sizer(sizer, win, n)
          sizer.add(win, Wx::SizerFlags.new(prop[n]))
          sizer.set_item_min_size(win, Wx::Size.new(minsize[n], -1))
        end
      end
      @ltd_klass.new(*args)
    end

  end

  LayoutTestData = [
    # some really simple cases (no need to permute those, they're
    # symmetrical anyhow)
    _ltd( [ 1, 1, 1, ], [  50,  50,  50, ], 150, [  50,  50,  50, ], true ),
    _ltd( [ 2, 2, 2, ], [  50,  50,  50, ], 600, [ 200, 200, 200, ], true ),

    # items with different proportions and min sizes when there is enough
    # space to lay them out
    _ltd( [ 1, 2, 3, ], [   0,   0,   0, ], 600, [ 100, 200, 300, ] ),
    _ltd( [ 1, 2, 3, ], [ 100, 100, 100, ], 600, [ 100, 200, 300, ] ),
    _ltd( [ 1, 2, 3, ], [ 100,  50,  50, ], 600, [ 100, 200, 300, ] ),
    _ltd( [ 0, 1, 1, ], [ 200, 100, 100, ], 600, [ 200, 200, 200, ] ),
    _ltd( [ 0, 1, 2, ], [ 300, 100, 100, ], 600, [ 300, 100, 200, ] ),
    _ltd( [ 0, 1, 1, ], [ 100,  50,  50, ], 300, [ 100, 100, 100, ] ),
    _ltd( [ 0, 1, 2, ], [ 100,  50,  50, ], 400, [ 100, 100, 200, ] ),

    # cases when there is not enough space to lay out the items correctly
    # while still respecting their min sizes
    _ltd( [ 0, 1, 1, ], [ 100, 150,  50, ], 300, [ 100, 150,  50, ] ),
    _ltd( [ 1, 2, 3, ], [ 100, 100, 100, ], 300, [ 100, 100, 100, ] ),
    _ltd( [ 1, 2, 3, ], [ 100,  50,  50, ], 300, [ 100,  80, 120, ] ),
    _ltd( [ 1, 2, 3, ], [ 100,  10,  10, ], 150, [ 100,  20,  30, ] ),

    # cases when there is not enough space even for the min sizes (don't
    # permute in these cases as the layout does depend on the item order
    # because the first ones have priority)
    _ltd( [ 1, 2, 3, ], [ 100,  50,  50, ], 150, [ 100,  50,   0, ], true ),
    _ltd( [ 1, 2, 3, ], [ 100, 100, 100, ], 200, [ 100, 100,   0, ], true ),
    _ltd( [ 1, 2, 3, ], [ 100, 100, 100, ], 150, [ 100,  50,   0, ], true ),
    _ltd( [ 1, 2, 3, ], [ 100, 100, 100, ],  50, [  50,   0,   0, ], true ),
    _ltd( [ 1, 2, 3, ], [ 100, 100, 100, ],   0, [   0,   0,   0, ], true ),
  ]

  def test_size_3
    child = [Wx::Window.new(win, Wx::ID_ANY),
             Wx::Window.new(win, Wx::ID_ANY),
             Wx::Window.new(win, Wx::ID_ANY)]

    LayoutTestData.each_with_index do |ltd, i|
      # the results shouldn't depend on the order of items except in the
      # case when there is not enough space for even the fixed width items
      # (in which case the first ones might get enough of it but not the
      # last ones) so test a couple of permutations of test data unless
      # specifically disabled for this test case
      3.times do |p|
        case p
        when 0
          # nothing, use original data
        when 1
          # exchange first and last elements
          ltd.prop[0], ltd.prop[2] = ltd.prop[2], ltd.prop[0]
          ltd.minsize[0], ltd.minsize[2] = ltd.minsize[2], ltd.minsize[0]
          ltd.sizes[0], ltd.sizes[2] = ltd.sizes[2], ltd.sizes[0]
        when 2
          # exchange the original third and second elements
          ltd.prop[0], ltd.prop[1] = ltd.prop[1], ltd.prop[0]
          ltd.minsize[0], ltd.minsize[1] = ltd.minsize[1], ltd.minsize[0]
          ltd.sizes[0], ltd.sizes[1] = ltd.sizes[1], ltd.sizes[0]
        end

        sizer.clear

        child.each_with_index { |c, j| ltd.add_to_sizer(sizer, c, j) }

        win.set_client_size(ltd.x, -1)
        win.layout

        child.each_with_index do |c, j|
          assert_equal(ltd.sizes[j], c.size.x,
                       "test #{i}, permutation #{p}: wrong size for child #{j} for total size #{ltd.x}")
        end

        # don't try other permutations if explicitly disabled
        break if ltd.dont_permute
      end
    end
  end

  def test_min_size
    child = Wx::Window.new(win, Wx::ID_ANY)
    child.set_initial_size([10, -1])
    sizer.add(child)

    # Setting minimal size explicitly must make get_min_size() return at least
    # this size even if it needs a much smaller one.
    sizer.set_min_size(100, 0)
    assert(sizer.get_min_size.x == 100)

    sizer.layout
    assert(sizer.min_size.x == 100)
  end

end
