<!--
# @markup markdown
# @title 6. wxRuby geometry classes
-->

# 6. wxRuby Geometry classes

## Size (Wx::Size) and position (Wx::Point and Wx::RealPoint)

The wxWidgets API has a lot methods that require either `wxSize`, `wxPoint` or both type of value as argument. Although 
this can be specified in C++ still relatively concise like 
```ruby
new wxFrame(nullptr, -1, "title", wxPoint(0,0), wxSize(500,400))
```
in Ruby this expands to the more verbose 
```ruby
Wx::Frame.new(nil, -1, 'title', Wx::Point.new(0,0), Wx::Size.new(500,400))
```
which starts to feel awkward to specify what are in essence just pairs of integers.

To provide a simpler, more compact and more Ruby-like, alternative the wxRuby API therefor supports specifying arrays
of integer (or float in case of Wx::RealPoint) pairs in (almost) all cases where `Wx::Size` or `Wx::Point` 
(or Wx::RealPoint) is expected. So the following code is equivalent to the previous code:
```ruby
Wx::Frame.new(nil, -1, 'title', [0,0], [500,400])
```

In addition `Wx::Size`, `Wx::Point` and `Wx::RealPoint` support parallel assignment semantics such that you can write code like
```ruby
  win.paint do | dc |
    # ...    
    x, y = win.get_position
    dc.draw_circle(x, y, 4)
    dc.draw_rectangle(x-4, y-4, 8, 8)
  end
```
instead of
```ruby
  win.paint do | dc |
    # ...    
    pos = win.get_position
    dc.draw_circle(pos.x, pos.y, 4)
    dc.draw_rectangle(pos.x-4, pos.y-4, 8, 8)
  end
```

Instances of these classes can also be converted (back) to arrays with their `#to_ary` methods.

Lastly wxRuby also extends the standard Ruby Array class with conversion methods to explicitly convert
arrays to `Wx::Size`, `Wx::Point` or `Wx::RealPoint`; respectively the `#to_size`, `#to_point` and `#to_real_point` 
methods.

## Areas (Wx::Rect)

Like `Wx::Size` and `Wx::Point` wxRuby supports parallel assignment for `Wx::Rect` such that you can write code like
```ruby
x, y, width, height = win.get_client_rect
```

Providing arrays of integers as alternative for `Wx::Rect` arguments is not supported as specifying `[0, 0, 20, 40]` is
ambiguous. This could either mean a rectangle with origin `x=0,y=0` and size `width=20,height=40` (`Wx::Rect.new(0,0,20,40)`)
or a rectangle from origin top left `x=0,y=0` to point bottom right `x=20,y=40` (`Wx::Rect.new(Wx::Point.new(0,0), Wx::Point.new(20,40))`).
