<!--
# @markup markdown
-->

# Installation of wxRuby3

## Installation of a wxRuby3 Gem

The wxRuby3 project provides gems on [RubyGems](https://rubygems.org) which can be installed with the
standard `gem install` command line this:

```sh
gem install wxruby3
 ```

On Linux systems this will install the source based gem which will automatically build the native wxruby3 extension
for the platform on which wxRuby3 is being installed.
On Windows systems a prebuilt binary gem is available for the latest stable release(s) of [RubyInstaller](https://rubyinstaller.org) 
installed rubies that will be installed by default if installing for that platform. Alternatively the source gem can be
installed on Windows by installing with explicit platform specification like this:

```sh
gem install wxruby3 --platform=ruby
```

When installing the source gem the following basic requirements apply:

- Git version control toolkit
- Ruby 2.5 or later (including development package)
- GNU g++ 4.8 or later on Linux, RubyInstaller+DevKit on Windows
- [SWIG](https://www.swig.org) 3.0.12 or later
- [Doxygen](https://www.doxygen.nl/)

Also a wxWidgets installation (version 3.2 or later) is required for which there are multiple options.

1. System installed wxWidgets version (including development package)<br>
   <br>
   This is the default method used when installing the source gem without any options.<br>
   The wxRuby build procedure will determine the availability and version of wxWidgets by locating and calling
   the `wx-config` utility script. In case no (compatible) wxWidgets version is found installation ends with an error.<br>
   Please note that even with this method a copy of the wxWidgets project will be checked out from GitHUb as the wxRuby3
   build procedure requires access to the wxWidgets interface specification sources (see [here](TODO) for more details). 
   

2. User installed wxWidgets version<br>
   <br>
   In case the being system installed on does not provide (a compatible) wxWidgets version or a specific (possibly updated)
   wxWidgets version is required the source gem can be installed using a user installed version like this (where the 
   `WXWIN` path should provide the location where the wxWidgets binaries are installed under `<wxwin path>/bin`):<br>

```sh
   gem install wxruby3 -- WXWIN=/path/to/wx/install 
```
   
3. Automatic installed wxWidgets version<br>
   <br>
   This is the easiest method when the being system installed on does not provide (a compatible) wxWidgets version (and 
   no specific user defined version is required) and can be used by installing the source gem like this (which will
   cause automatic checkout and building of the latest wxWidgets release (>= 3.2) from GitHub:


```sh
   gem install wxruby3 -- WITH_WXWIN=1
```

> **NOTE:** Be patient when installing the source gem. Building wxRuby3 takes a while and when wxWidgets is included event more. 

## Building from source

Checkout the wxRuby3 sources from [GitHub](https://github.com/mcorino/wxRuby3).

Basic requirements are the same as for installing the source gem. Gem dependencies are listed in the Gemfile in the root
of the wxRuby3 tree.

The wxRuby3 project provides a Rake based build system. Call `rake help` to get an overview of the available commands.
As mentioned there the `rake configure` command is required as the very first command. Call `rake configure[--help]` to
get a detailed overview of the options for this command.<br>
As with the source gem 3 options exist for the wxWidgets installation which will have to be specified to `rake configure`.  

When wxRuby3 has been configured the extensions can be build by calling the `rake build` command. The wxRuby3 build 
commands are executed using parallel task execution by default.

When the build has finished without errors the regression tests can be run by calling `rake test`.

For more details concerning the wxRuby3 development strategy and build options see [here](TODO). 
