<!--
# @markup markdown
# @title 11. wxRuby Drawing and Device Contexts
-->

# 11. wxRuby Drawing and Device Contexts (DC)

In wxRuby the Wx::DC class family provides functionality for drawing to windows, bitmaps, printers etc.

What most of these classes have in common is that actual drawing output is buffered until the time the 
device context object is destroyed.
For this reason the common practice in wxWidgets C++ code would be to create temporary DC objects on the
stack and draw on them while they are in scope (for several classes it is even strongly advised to never create
them any other way and to never keep objects alive out of scope). When leaving the scope these object would than be 
automatically destroyed and the any buffered output flushed to the final target.

In Ruby this approach is impossible as Ruby is a purely dynamic language and does not **this kind** of scope bound
life cycles. Any DC object created would have to be dynamically created and due to the properties of the GC driven
life cycles could well be kept alive beyond the scope of it's creation. This will not always cause problems but could
and does not really have an upside.

To prevent confusion and potential problems wxRuby defines all `Wx::DC` derived classes to be abstract classes that
cannot be instantiated using `new`. Rather all `Wx::DC` derived classes provide `#draw_on` factory methods to create 
temporary dc objects that will be passed on to blocks given and will only exist for the duration of the execution of
the block. This will guarantee proper DC cleanup when leaving it's usage scope.

> Note that it is a **BAD** idea to think about storing the dc reference provide to the block for later access!

A typical usage of a `#draw_on` method would be:

```ruby
    myTestBitmap1x = Wx::Bitmap.new(60, 15, 32)
    Wx::MemoryDC.draw_on(myTestBitmap1x) do |mdc|
      mdc.set_background(Wx::WHITE_BRUSH)
      mdc.clear
      mdc.set_pen(Wx::BLACK_PEN)
      mdc.set_brush(Wx::WHITE_BRUSH)
      mdc.draw_rectangle(0, 0, 60, 15)
      mdc.draw_line(0, 0, 59, 14)
      mdc.set_text_foreground(Wx::BLACK)
      mdc.draw_text("x1", 0, 0)
    end
```

## Windows, Wx::PaintDC and Wx::AutoBufferedPaintDC

The `Wx::PaintDC` and `Wx::AutoBufferedPaintDC` classes provide `#draw_on` methods just like all other DC classes but
this is mostly to be consistent.

In this case it is recommended to instead use the `Wx::Window#paint` or `Wx::Window#paint_buffered` methods as these
provide some optimizations with regard to automatically detecting is the methods are called inside `Wx::EVT_PAINT` 
handlers (which should normally be the case) or not.

So the typical way to do buffered painting inside a windows `Wx::EVT_PAINT` handler would be something like:

```ruby
  def on_paint(_event)
    self.paint_buffered do |dc|
      # ... do some drawing ...
    end
  end
```
