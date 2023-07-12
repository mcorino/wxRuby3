<!--
# @markup markdown
-->

# Installation of wxRuby3

## Minimal requirements for installing wxRuby3

The minimal requirements for installing any source based setup (gem, source package or Github clone) of wxRuby3 are:

| Sofware                                       | Notes                                                                                                                                                                                                                           |
|-----------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ruby                                          | A supported version of the Ruby interpreter needs to be installed.                                                                                                                                                              |
| C++ compiler<br>(incl. dev tools like `make`) | On linux a recent version of the GNU C++ compiler (with c++-14 support) needs to be installed<br>On Windows the RubyInstaller MSYS2-Devkit needs to be installed<br>On MacOS XCode with commandline tools needs to be installed |
| Git version control toolkit                   |                                                                                                                                                                                                                                 |
| SWIG >= 3.0.12                                | On MacOS install [Homebrew](https://brew.sh/) and than `brew install swig`                                                                                                                                                      |
| Doxygen (>= 1.9.1, <= 1.9.6)                  | Doxygen > 1.9.6 has changes that cause problems with the wxWidgets doxygen files.<br>On MacOS: `brew tap mcorino/wxruby3` and than `brew install doxygen@1.9.6` (default brew recipe installs 1.9.7)                            |

The wxRuby3 build process requires `git` to clone a copy of the wxWidgets Github repository to extract the interface 
specifications from.<br>
The wxRuby3 build process needs doxygen to generated XML files containing wxWidgets interface specs which are used to 
generate SWIG interface definitions from which SWIG to generates C++ source code for the wrapper interfaces from
which the native extension is compiled.

## Installation of a wxRuby3 Gem

The wxRuby3 project provides gems on [RubyGems](https://rubygems.org) which can be installed with the
standard `gem install` command line this:

```shell
gem install wxruby3
 ```

On Linux systems this will install the source based gem which will automatically build the native wxruby3 extension
for the platform on which wxRuby3 is being installed.
On Windows systems a prebuilt binary gem is available for the latest stable release(s) of [RubyInstaller](https://rubyinstaller.org) 
installed rubies that will be installed by default if installing for that platform (including an embedded, latest 
stable version, wxWidgets installation).<br>
Alternatively the source gem can be installed on Windows by installing with explicit platform specification like this:

```shell
gem install wxruby3 --platform=ruby
```

When installing the source gem the minimal requirements listed above apply.

Also a wxWidgets installation (version 3.2 or later) is required for which there are multiple options.

1. System installed wxWidgets version (including development package)<br>
   <br>
   This is the default method used when installing the source gem without any options.<br>
   The wxRuby build procedure will determine the availability and version of wxWidgets by locating and calling
   the `wx-config` utility script. In case no (compatible) wxWidgets version is found installation ends with an error.<br>
   Please note that even with this method a copy of the wxWidgets project will be checked out from GitHUb as the wxRuby3
   build procedure requires access to the wxWidgets interface specification sources which are not normally part of any of 
   the standard distribution packages.
   

2. User installed wxWidgets version<br>
   <br>
   In case the system being installed on does not provide (a compatible) wxWidgets version or a specific (possibly updated)
   wxWidgets version is required the source gem can be installed using a user installed version like this (where the 
   `WXWIN` path should provide the location where the wxWidgets binaries are installed under `<wxwin path>/bin`):<br>

```shell
   gem install wxruby3 -- WXWIN=/path/to/wx/install 
```
   
3. Automatic installed, embedded, wxWidgets version<br>
   <br>
   This is the easiest method when the system being installed on does not provide (a compatible) wxWidgets version (and 
   no specific user defined version is required) and can be used by installing the source gem like this (which will
   cause automatic checkout and building of the latest stable wxWidgets release (>= 3.2) from GitHub:

```shell
   gem install wxruby3 -- WITH_WXWIN=1
```

In case of option **2** it is also possible to do the doxygen XML generation as part of the wxWidgets user installation
and use that for the gem installation. In that case the user is required to generate the XML interface specs using the
`regen` script found in the `docs/doxygen` folder of the wxWidgets installation after which the XML output folder can be 
provided to the gem installation as follows:

```shell
   gem install wxruby3 -- WXWIN=/path/to/wx/install WXXML=/path/to/wx/doxygen/xml
```

Please also not that in case of option two the user is responsible to make sure the wxWidgets shared libraries can be
found by the system's dynamic loader at runtime.

> **NOTE:** Be patient when installing the source gem. Building wxRuby3 takes a while and when wxWidgets is included event more. 

## Building from source

Checkout the wxRuby3 sources from [GitHub](https://github.com/mcorino/wxRuby3) or download and unpack a release package.

Requirements are the same as for installing the source gem. Gem dependencies are listed in the Gemfile in the root
of the wxRuby3 tree and should be installed by executing `bundle install`.<br>
To be able to generate HTML documentation the optional `:documentation` group should be included.<br>
To be able to run the Rake memory check task the option `:develop` group should be included.

The wxRuby3 project provides a Rake based build system. Call `rake help` to get an overview of the available commands.
As mentioned there the `rake configure` command is required as the very first command. Call `rake configure[--help]` to
get a detailed overview of the options for this command.<br>
As with the source gem 3 options exist for the wxWidgets installation which will have to be specified to `rake configure`.  

When wxRuby3 has been configured the extensions can be build by calling the `rake build` command. The wxRuby3 build 
commands are executed using parallel task execution by default.

When the build has finished without errors the regression tests can be run by calling `rake test`.

For more details concerning the wxRuby3 development strategy and build options see [here](TODO). 
