<!--
# @markup markdown
# @title 10. wxRuby Locating and loading art
-->

# 10. wxRuby Locating and loading art

## Introduction

With C++ wxWidgets applications art (icons, bitmaps, cursors, images) can be loaded in a variety 
of ways from embedded resources (platform specific binary resources or embedded XPM files) or from
binary datasets retrieved from some data source.  

With wxRuby that is for various reasons not a viable option so we are left with the option to
load art from files. In and of itself that option is not really too bad but for the issue of locating 
the art files.
Art that is part of the application's design will preferably be stored with the source code but there
is not standard for this nor is there any standard support for locating those files from the application
code like there is for `require`-s of other code modules.

The wxRuby framework provides a convenience module `Wx::ArtLocator` to assist in that respect.
Wx::ArtLocator aims on the one side to standardize folder structures for storing art files and on the
other side to provide runtime support for locating those files from code.

The main locator method provided is:

```ruby
  module Wx::Locator
    def self.find_art(art_name, art_type: nil, art_path: nil, art_section: nil, bmp_type: nil)
      # ...
    end
  end
```

The 'art_name' argument should provide the base name for matching art files and can be specified as either
String or Symbol.

## Storage locations

Wx::ArtLocator defines a standardized directory structure that is assumed to be used for application art
file storage.
Working from a certain (application defined) base search path ('art_path' argument) this structure looks like this:

    <art_path>
              \art
                  \<art_section>
                                \<art_type>

Where '<art_path>' is an application supplied search path, 'art' is the default name for Art folders (this can be overridden by an application specific name),
'<art_section>' is an application defined id allowing sub-categorizing art and '<art_type>' is the type of art indicator 
(which can be 'icon', 'bitmap', 'cursor', 'image').
Art files can be located at any level in this hierarchy and all sub levels in this hierarchy are optional. 
When locating files the art locator will test a file's existence at all levels starting with the
deepest level working it's way up returning the absolute path of the first file found this way.

So locating an art file would involve testing for the file at the following paths:
1. \<art_path>/art/<art_section>/<art_type>/
2. \<art_path>/art/<art_section>/
3. \<art_path>/art/
4. \<art_path>/

The first location can be skipped by specifying `nil` for 'art_type'.

## Bitmap types

Based on platform and specified '<art_type>' (and optionally a specific Wx::BitmapType) art files with a specific
range of extensions will be tested in a specific order.
For example for locating an `:icon` (<art_type>) on platform 'WXGTK' the locator will test the preferred extension
'.xpm' followed by any of supported extensions of all other supported bitmap types.
For platform 'WXMSW' however the same search would test only the extensions '.ico' and '.xpm' (in that
order).
Specifying a specific Wx::BitmapType for a search will restrict the search to testing only the extensions supported
for the specified Wx::BitmapType.

## Search paths

To prevent having to specify base search path for every location request Wx::Locator provides 2 options.

When an explicit specification of a base search path ('art_path) is omitted from a location request the locator
will determine one by using `Kernel#caller_locations` to extract the absolute path for the source file containing
the caller's code. The result of `File.dirname(src_path)` is than used as base search path.
If 'art_section' is also omitted the result of `File.basename(src_path, '.*')` will be used instead.

This means that calling `Wx::ArtLocator.find_art` from some code in file `/some/lib/path/to/ruby/code.rb` without 
specifying both 'art_path' and 'art_section' would result in looking for an art file with the base search path
being `/some/lib/path/to/ruby/` and using `code` as 'art_section'.

It is also possible to add 'application global' search paths with the method `Wx::ArtLocator.add_search_path`.
Search paths added in this way will be tested after failing to find any matching art file at the initial 'art_path'
location. The same location steps apply to these search paths as with the initial 'art_path' (see above).

## Convenience methods

Based on the Wx::ArtLocator implementation wxRuby additionally provides a number of convenience methods to
easily create Icons, Bitmaps, Cursors and Images from simple ids (symbols).
These methods mimic the ease of use of the `wxICON` and `wxBITMAP` macros used with C++ wxWidgets such that
creating an Wx::Icon instance could be as easy as:

```ruby
    frame.icon = Wx::Icon(:sample)
```

As these methods apply the same search path 'automagic' as `Wx::ArtLocator.find_art` (see [Search paths](#Search-paths))
this would search for an art file with base name 'sample' and an appropriate extension (like '.xpm' for the 'WXGTK' platform)
in a location starting at the directory in which the caller's code is stored (applying the steps described above).
