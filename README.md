[![Linux wxGTK](https://github.com/mcorino/wxRuby3/actions/workflows/linux.yml/badge.svg)](https://github.com/mcorino/wxRuby3/actions/workflows/linux.yml)
[![Windows wxMSW](https://github.com/mcorino/wxRuby3/actions/workflows/msw.yml/badge.svg)](https://github.com/mcorino/wxRuby3/actions/workflows/msw.yml)
[![Mac wxOSX](https://github.com/mcorino/wxRuby3/actions/workflows/mac.yml/badge.svg)](https://github.com/mcorino/wxRuby3/actions/workflows/mac.yml)

[![License](https://img.shields.io/badge/license-MIT-yellowgreen.svg)](LICENSE)
[![Gem Version](https://badge.fury.io/rb/wxruby3.svg)](https://badge.fury.io/rb/wxruby3)
[![Documentation](https://img.shields.io/badge/docs-pages-blue.svg)](https://mcorino.github.io/wxRuby3)
[![Chat](https://img.shields.io/gitter/room/mcorino/wxruby)](https://gitter.im/mcorino/wxruby3)

# README for wxRuby3

![Logo](assets/logo.svg "wxRuby3")

Reviving wxRuby

## Introduction

wxRuby3 is a cross-platform GUI library for Ruby, based on the mature [wxWidgets](https://wxwidgets.org)
GUI toolkit for C++. It uses native widgets wherever possible, providing
the correct look, feel and behaviour to GUI applications on Windows, OS
X and Linux/GTK. wxRuby aims to provide a comprehensive solution to
developing professional-standard desktop applications in Ruby. 

## Usage examples

### Hello world

wxRuby3 is very easy to use.

```ruby
require 'wx'

Wx::App.run do
  Wx::Frame.new(nil, title: 'Hello world!').show
end
```

![Hello_World](assets/hello_world_combi.png "Hello World sample")

### Hello Button

Anyone who is familiar with wxWidgets should feel right at home since the API may be Ruby-fied, it is still easily 
recognizable (but being Ruby-fied allowing for elegant and compact coding). And for those that do not have previous 
experience, do not fear, wxRuby3 comes with detailed [documentation](https://mcorino.github.io/wxRuby3/file.00_starting.html) and lots of examples and tests.    

```ruby
require 'wx'

class TheFrame < Wx::Frame
  def initialize(title)
    super(nil, title: title)
    panel = Wx::Panel.new(self)
    button = Wx::Button.new(panel, label: 'Click me')
    button.evt_button(Wx::ID_ANY) { Wx.message_box('Hello. Thanks for clicking me!', 'Hello Button sample') }
  end
end

Wx::App.run { TheFrame.new('Hello world!').show }
```

![Hello_Button_Clicked](assets/hello_button_clicked_combi.png "Hello Button sample clicked")


## wxRuby3 licence

wxRuby3 is free and open-source. It is distributed under the liberal
MIT licence which is compatible with both free and commercial development.
See [LICENSE](LICENSE) for more details.

### wxRuby3 and wxWidgets

If you distribute (your) wxRuby3 (application) with a binary copy of wxWidgets,
you are bound to the requirements of the copy of wxWidgets within. Fortunately,
those requirements do not impose any serious restrictions.

### wxWidgets License Summary (from wxWidgets)

In summary, the licence is LGPL plus a clause allowing unrestricted
distribution of application binaries. To answer a FAQ, you don't have to
distribute any source if you wish to write commercial applications using
wxWidgets.

### Required Credits and Attribution

Generally, neither wxWidgets nor wxRuby3 require attribution, beyond
retaining existing copyright notices. However, if you build your own
custom wxWidgets library, there may be portions that require specific
attributions or credits, such as TIFF or JPEG support. See the wxWidgets
README and license files for details.
See [here](CREDITS.md) for more details on and acknowledgement of the developers 
of these products.

## FAQ
 
### What platforms and operating systems are supported in wxRuby3?

Currently the following are fully supported:

| Platform                                                                   | Ruby version(s) | wxWidgets version(s) |
|----------------------------------------------------------------------------|-----------------| --- |
| Windows 10 (tested)<br>(most likely also Windows 11)                       | Ruby >= 2.5<br>(RubyInstaller MSYS2-DevKit) | wxWidgets >= 3.2 |
| Linux (tested; any AMD-64 distribution)<br>(most likely also i686 and ARM) | Ruby >= 2.5 | wxWidgets >= 3.2 |
| MacOS >= 10.10 using Cocoa (tested on AMD-64 and ARM64 M2 Chip)            | Ruby >= 2.5 | wxWidgets >= 3.2 |

Support for other platforms is not being actively developed at present,
but patches are welcome. It is likely to be much simpler to get wxRuby
working on similar modern systems (eg FreeBSD or Solaris with GTK) than
on legacy systems (eg Windows 98, Mac OS 9).

### How can I install wxRuby3?

wxRuby3 is distributed as a Ruby gem on [RubyGems](https://rubygems.org).<br>
Apart from a regular source-only version of the gem there is also a binary gem version for Windows 10 provided (for the 
latest stable Ruby version at the time of publishing) which includes an embedded wxWidgets installation (also latest 
stable version). 

Installing the binary gem version on Windows requires no additional software to be installed except for a supported 
version of the Ruby interpreter.<br>
To install the source-only gem the following software is required:

| Sofware                                       | Notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ruby                                          | A supported version of the Ruby interpreter needs to be installed.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| C++ compiler<br>(incl. dev tools like `make`) | On linux a recent version of the GNU C++ compiler (with c++-14 support) needs to be installed<br>On Windows the RubyInstaller MSYS2-Devkit needs to be installed<br>On MacOS XCode with commandline tools needs to be installed                                                                                                                                                                                                                                                                                                                                                                                                              |
| Git version control toolkit                   |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| SWIG >= 3.0.12                                | On MacOS install [Homebrew](https://brew.sh/) and than `brew install swig`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
| Doxygen (>= 1.9.1, <= 1.9.6)                  | Doxygen > 1.9.6 has changes that cause problems with the wxWidgets doxygen files.<br>On MacOS: `brew tap mcorino/wxruby3` and than `brew install doxygen@1.9.6` (default brew recipe installs 1.9.7)                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| wxWidgets >= 3.2 (*OPTIONAL*)                 | On Linux most distributions provide system installable (development) packages for wxWidgets providing a supported version. Alternatively you can fairly easily install your own preferred version manually (see the [wxWidgets](https://wxwidgets.org) project for details).<br>On Windows and MacOS the process is less straightforward (also here see the [wxWidgets](https://wxwidgets.org) project for details).<br>The wxRuby3 source-only gem can also be installed using a private local wxWidgets installation or an embedded installation (most likely preferred on Windows and MacOS). See [INSTALL](INSTALL.md) for more details. |    

In case the prerequisites above are met the (source-only or binary) gem can be installed executing the following command:

```shell
gem install wxruby3
```

### Where can I ask a question, or report a bug?

Use GitHUb Issues.

When asking a question, if something is not working as you expect,
please provide a *minimal*, *runnable* sample of code that demonstrates
the problem, and say what you expected to happen, and what actually
happened. Please also provide basic details of your platform, Ruby,
wxRuby and wxWidgets version, and make a reasonable effort to find answers 
in the archive and documentation before posting. People are mostly happy
to help, but it's too much to expect them to guess what you're trying to
do, or try and debug 1,000 lines of your application.
Very important also; do not use offensive language and be **polite**.

### How can I learn to use wxRuby?

wxRuby3 is a large API and takes some time to learn. The wxRuby3
distribution comes with numerous samples which illustrate how to use
many specific parts of the API. A good one to start with is the
'minimal' sample, which provides an application skeleton. All the
bundled samples are expected to work with current wxRuby3, although
some use a more modern coding style than others.

Complete (more or less) wxRuby API documentation should be part of any
complete wxRuby3 build. This tends to focus on providing a reference
of all available modules, classes and methods and how to use specific 
classes and methods, rather than on how to construct an application 
overall.
This documentation (for the latest release) is also available online
[here](https://mcorino.github.io/wxRuby3/file.00_starting.html).

One of the advantages of wxRuby3 is the much larger ecosystem of
wxWidgets and wxPython resources out there. There is a book for
wxWidgets, "Cross-Platform Programming in wxWidgets", which can be freely
downloaded as a PDF. This provides very comprehensive coverage of the
wxWidgets API in C++. The code may not be directly useful but the
descriptions of how widgets and events and so forth work are almost
always relevant to wxRuby3 (and should be fairly easily relatable).

When using a search engine to find answers about a wxRuby3 class, it can
be worth searching for the same term but with 'wx' prepended. For
example, if you wanted answers about the "Grid" class, try searching for
"wxGrid" as this will turn up results relating to wxWidgets and wxPython
which may be relevant.

### What wxWidgets features are supported by wxRuby3?

wxRuby supports almost all of the wxWidgets 3.2+ GUI API, providing over
600 classes in total. wxWidgets classes that provide general and/or non-GUI 
programming support features, such as strings, networking, threading, database
access and such are not and will never be ported, as it's assumed that 
in all these cases it's preferable to use pure Ruby features.

If you know of a feature in wxWidgets that you would like to see
supported in wxRuby3 you are free to ask but do not **EXPECT** unconditional 
agreement or immediate response. 

### How does wxRuby3 relate to the wxRuby 2.0 (and even older 0.6.0) release?

wxRuby 0.6.0 was the last in a series of releases developed using a
different approach in the early days of wxRuby. Work on this series
stopped in early 2005, in favour of what became wxRuby 2.0. This project
in turn stopped being supported in 2013.
Several years of development have passed for wxWidgets and Ruby respectively,
improving code quality, adding new classes and new language features.
In 2022 I finally found the time and the inspiration to pick up this project
with the idea of reviving it to build some applications I had in mind.
wxRuby 3 intents to provide Ruby interfaces for all relevant (!) wxWidget
classes of the latest version 3.2 and beyond. 
Building on the experiences of the previous wxRuby (2) developments as well
as the wxPython Phoenix project it is expected to provide a better and more
maintainable solution.

### I am getting an error trying to install or compile wxRuby3

Please double-check the instructions above and in the [INSTALL](INSTALL.md) document and search issue archives. If 
this doesn't help, please post your question using GitHub Issues.

### Is there another, more declarative way, for writing wxRuby3 desktop GUI applications?

Yes. [Glimmer DSL for WX](https://github.com/AndyObtiva/glimmer-dsl-wx) enables software engineers to build GUI using wxruby3 following the Ruby way with the least amount of code possible. That is by offering a minimalistic declarative high-level DSL that maps visually to the way software engineers think about the GUI hierarchy in addition to adopting Rails' strategy of Convention over Configuration via smart defaults and automation of wxruby3 low-level details. You can check out the [Glimmer DSL for WX README "Coming From wxruby3" section](https://github.com/AndyObtiva/glimmer-dsl-wx#coming-from-wxruby3) for more information on how to translate wxruby3 apps to [Glimmer DSL for WX](https://github.com/AndyObtiva/glimmer-dsl-wx) syntax.
