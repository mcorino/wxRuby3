<!--
# @markup markdown
-->

# Installation of wxRuby3

## Default installation

The wxRuby3 gem provides a **worry-free** installation for all supported platforms.

The default gem installation command

```shell
gem install wxruby3
``` 

and the setup command  

```shell
wxruby setup
```

for installations without prebuilt binary packages should always result in a successfully installed wxRuby3 version.

> **NOTE**<br>
> Currently installing the wxRuby3 gem for the system supplied Ruby on MacOSX systems does not work.<br>
> The user is therefor required to install a Ruby interpreter using either [MacPorts](https://www.macports.org/) (both 
> privileged and user installations are supported) or [Homebrew](https://brew.sh/) or Ruby installers/version managers 
> like [ruby-install](https://github.com/postmodern/ruby-install) or [RVM](https://rvm.io) (only user installations 
> supported) .

[Below](INSTALL.md#installing-software-requirements) more details regarding the software requirements for wxRuby3, the 
setup procedure and various options to tweak and customize the installation (including platform specific details for 
Linux, Windows and MacOSX) are described.

## Bundled CLI

Installing the wxRuby3 gem will also install the bundled `wxruby` CLI binary.

For source gem installations the CLI will initially only provide the `check` and `setup` commands.

For finalized installations (either from binary packages or source builds) the *setup* command is replaced by other 
utility commands providing the ability to run the bundled regression tests and access (run or copy) the bundled examples.<br>
Run the following command to see the available options at any time:

```shell
wxruby -h
```

## Binary packages

The wxRuby3 gem installation process will by default attempt to match the current platform to any standard available
binary packages and if found install the matched package.

Binary packages are archives (custom format) containing prebuilt (extension) library artifacts for a single specific
platform. Any such platform is identified by:

- CPU architecture (x86_64, ARM64, etc.)
- Operating system type (linux, darwin, windows, etc.)
- OS distribution and release number (except for windows)
- Ruby ABI version (i.e. {major}.{minor})

The standard available binary packages provide both the wxRuby3 extension libraries as well as the embedded wxWidgets 
libraries the extension libraries were built for.<br>
This is however not mandatory. User created binary packages can be built for separately installed (either distribution 
or user provided) wxWidgets libraries.

### Standard packages

The standard release artifacts at [Github](https://github.com/mcorino/wxRuby3/releases) provide a selection of binary
packages for all supported OS platforms which are automatically built and uploaded for every release.<br>
The following tables lists the packages provided by the current wxRuby3 release process:

| OS      | Distributions                 | Architectures           | Rubies                                             |
|---------|-------------------------------|-------------------------|----------------------------------------------------|
| Linux   | OpenSuSE Leap (latest stable) | x86_64 <b>and</b> ARM64 | Distro provided Ruby <b>and</b> Latest stable Ruby |  
| Linux   | Fedora (latest stable)        | x86_64 <b>and</b> ARM64 | Distro provided Ruby <b>and</b> Latest stable Ruby |  
| Linux   | Debian (latest stable)        | x86_64 <b>and</b> ARM64 | Distro provided Ruby <b>and</b> Latest stable Ruby |  
| Linux   | Ubuntu (latest stable)        | x86_64 <b>and</b> ARM64 | Distro provided Ruby <b>and</b> Latest stable Ruby |
| Windows | NA                            | x86_64                  | Latest stable Ruby                                 |
| OSX     | MacOSX 12                     | x86_64 <b>and</b> ARM64 | Latest stable Ruby                                 |
| OSX     | MacOSX 13                     | x86_64 <b>and</b> ARM64 | Latest stable Ruby                                 |
| OSX     | MacOSX 14                     | ARM64                   | Latest stable Ruby                                 |

### User created packages

Users can create their own wxRuby3 binary packages by building from source ([see here](#building-from-source)) and after
successfully having built the wxWidgets extension libraries execute the `rake binpkg` command.<br>
This creates two files in the `pkg` folder with names like<br>
`wxruby3_{distribution}_ruby{abi version}_v{wxruby version}_{os}_{arch}.pkg`<br>
and<br>
`wxruby3_{distribution}_ruby{abi version}_v{wxruby version}_{os}_{arch}.sha`<br>
where the `.pkg` file is the actual binary archive and the `.sha` file is the associated SHA256 digest signature of the 
archive contents.

Both files are required for installation and should be located at the same path (either local path or http(s) url).<br>
[See here](#the-package-option) for information on how to use user created binary packages with the wxRuby3 gem installation process.

## Software requirements for wxRuby3

The software requirements for setting up a wxRuby3 runtime environment are:

| Sofware                                       | Notes                                                                                                                                                                                                                                                                                                                        |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ruby                                          | A supported version of the Ruby interpreter needs to be installed. This is an absolute requirement for any installation as one cannot install gems without Ruby and building from source requires Ruby to drive the build process.                                                                                           |
| C++ compiler<br>(incl. dev tools like `make`) | Required for a source based installation to build wxWidgets (optionally) and the wxRuby extension libraries.<br/>On linux a recent version of the GNU C++ compiler (with c++-14 support) is required.<br>On Windows the RubyInstaller MSYS2-Devkit would be required.<br>On MacOS XCode with commandline tools would be required. |
| Git version control toolkit                   | Required for a source based installation in to (possibly) clone a copy of the wxWidgets Github repository or to clone the Github repository of wxRuby3 itself for a fully source based installation.                                                                                                                         |
| Doxygen (>= 1.9.1)                            | Required for building the wxRuby3 extension libraries for a source based installation. [**1**]                                                                                                                                                                                                                               |
| SWIG >= 3.0.12                                | Required for building the wxRuby3 extension libraries for a source based installation. [**2**]                                                                                                                                                                                                                               |
| Patchelf (Linux) or install_name_tool (OSX)   | Required for setting up embedded wxWidgets libraries. [**3**]                                                                                                                                                                                                                                                                |
| wxWidgets (>= 3.2)                            | Runtime libraries required for any wxRuby3 installation (either from embedded wxWidgets installation or a system or user installation; see below).                                                                                                                                                                           |

Except for Ruby itself all other software requirements can be handled by the **worry-free**, fully automated installation procedure of wxRuby3.

But of course any of these requirements can also be fulfilled explicitly with self controlled steps **before** starting the
wxRuby3 installation procedure. See the platform specific sections of [Installing software requirements](INSTALL.md#installing-software-requirements) for details on 
how to go about that. 

[**1**] The wxRuby3 build process needs doxygen to generated XML files containing wxWidgets interface specs which are used to 
generate interface definitions for SWIG

[**2**] The wxRuby3 build process uses SWIG to generate C++ source code for the wrapper interfaces from
which the native extensions are compiled. Both SWIG version 3 and version 4 are supported.

[**3**] The wxRuby3 build process uses these tools to adjust the shared library load paths ('rpath' setting) in case of embedded wxWidgets libraries.

### wxWidgets installation variants

wxRuby3 can be built and installed for 3 different types of wxWidgets installations:

1. A system installation of wxWidgets libraries and development files.<br>
   This actually only has real meaning on Linux where this corresponds with installing distribution provided packages. 
   On MacOSX and Windows this only means that libraries are installed (as a user addon since no standard distribution 
   packages exist for these platforms but possibly using the administrator account) such that they can be loaded using 
   the default library load paths and the `wx-config` tool is executable from the default search path.<br>
   This kind of installation is automatically detected and no special setup options are required for the wxRuby3 installation procedure.  
2. A user installation of wxWidgets libraries and development files.<br>
   This is the most likely scenario for a development setup of wxRuby3 where a special (possibly updated) release of 
   wxWidgets is installed to build wxRuby3 for.<br>
   In this case the libraries and development files are most likely not found in standard locations and the wxRuby3 
   installation procedure will require specific options to have these locations provided. 
3. An 'embedded' installation of wxWidgets setup by the wxRuby3 installation procedure.<br>
   This is the default when using a standard binary package or when installing from source and the setup procedure does 
   not detect a (compatible!) system installation or if an option has been provided explicitly specifying to install an 
   embedded wxWidgets version.

Please note that in case of option **2** the user is responsible to make sure the wxWidgets shared libraries can be
found by the system's dynamic loader at runtime.

As described with option **3** a wxWidgets system installation must be compatible (>= version 3.2) to be selected for 
source installation. In case the installed version does not meet this requirement it is ignored as if not installed.

For more information on how to install wxWidgets see the [Installing software requirements](INSTALL.md#installing-software-requirements) section below.

## wxRuby3 gem installation details 

The wxRuby3 project provides a gem on [RubyGems](https://rubygems.org) which can be installed with the
standard `gem install` command line this:

```shell
gem install wxruby3
 ```

Alternatively the gem can be downloaded from the [Github release assets](https://github.com/mcorino/wxRuby3/releases) and
stored locally. This local gem can than be installed like this:

```shell
gem install /path/to/local/wxruby3.gem
```

This default installation command will allow the wxRuby3 installation process to scan available standard binary packages
([see here](#standard-packages)) for a match to the platform being installed on and install any matched package or revert
to a source install if none matched.<br>
This command will therefor succeed if:
- a matching binary package could be successfully downloaded and installed;
- the installation reverted to source install.

This command only fails when:
- a matching digest signature for the downloaded binary package could not be downloaded;
- the digest signature did not match the downloaded package contents.

> The result of successfully installing the gem on a Linux platform should be something like this:
> ```
> $ gem install wxruby3 
> Building native extensions. This could take a while...
> 
> The wxRuby3 Gem has been successfully installed including the 'wxruby' utility.
> 
> In case no suitable binary release package was available for your platform you  
> will need to run the post-install setup process by executing:
> 
> $ wxruby setup
> 
> To check whether wxRuby3 is ready to run or not you can at any time execute the
> following command:
> 
> $ wxruby check
> 
> Run 'wxruby check -h' for more information.
> 
> When the wxRuby3 setup has been fully completed you can start using wxRuby3.
> 
> You can run the regression tests to verify the installation by executing:
> 
> $ wxruby test
> 
> The wxRuby3 sample explorer can be run by executing:
> 
> $ wxruby sampler
> 
> Have fun using wxRuby3.
> 
> Run 'wxruby -h' to see information on the available commands.
> 
> Successfully installed wxruby3-0.9.8
> Parsing documentation for wxruby3-0.9.8
> Installing ri documentation for wxruby3-0.9.8
> Done installing documentation for wxruby3 after 2 seconds
> 1 gem installed
> ```

### Gem installation options

Two options are available to control the wxRuby3 gem installation process.

#### The `prebuilt` option

The `prebuilt=none|only` option can be used to either prevent binary package matching and installation (`prebuilt=none`)
or make binary package installation mandatory (`prebuilt=only`).

The following command therefor forces a wxRuby3 source installation and will never fail: 

```shell
gem install wxruby3 -- prebuilt=none
```

And the following command will force binary package installation and fails if no matching package could be installed:

```shell
gem install wxruby3 -- prebuilt=only
```

#### The `package` option

The `package=URL` option can be used to explicitly specify a binary package to install. This option implies `prebuilt=only`.
No package matching will be performed so mismatched binary packages will cause wxRuby3 to fail after installation.<br>
The `URL` can be specified as:
- an <b>absolute</b> local path like `/path/to/binary/package.pkg`
- an absolute `file://` URI like `file:///path/to/binary/package.pkg`
- an `http://` or `https://` URL

In all cases the associated `.sha` file <b>must</b> be located at the same path as the package file itself. If not the
installation will fail as well as when the signature does not match the digest of the package contents.

### Gem source setup

As said a gem-based source installation requires an additional command is to build the actual wxRuby3 extension libraries 
for the platform installing on which is a wxRuby3 CLI command installed by the gem:

```shell
wxruby setup
```

The wxRuby3 CLI `wxruby` is installed by all wxRuby3 gems. In case of the source gem initially the CLI will provide only 
the commands `wxruby setup` (to finish wxRuby3 extension installation) and `wxruby check`.

For most (user) installations the default setup command as shown above will suffice nicely. In this case the setup 
(or installation) procedure will analyze the system to see if it meets the software requirements described above and if not
collect information on what is missing and needs to be added to finish the wxRuby3 installation. In order this would check:

- availability of the `doxygen` tool
- availability of the `swig` tool
- availability of the `git` tool
- availability of a (compatible) system installation of wxWidgets
- development tools and libraries required for an embedded wxWidgets installation (in case no system installation is used) 

If any required software needs to be added the setup procedure will ask consent (showing what it intends to do) and, if given,
install the missing software using appropriate tooling for the platform (on Linux standard distribution installers which 
may require a 'sudo' password and on MacOSX using either [MacPorts](https://www.macports.org/) or [Homebrew](https://brew.sh/)).

> Running the setup command will look something like this:
> ```
> $ wxruby setup
> 
> ---            
> Now running wxRuby3 post-install setup.
> This will (possibly) install required software, build the wxWidgets libraries,
> build the native wxRuby3 extensions and generate the wxRuby3 reference documentation.
> Please be patient as this may take quite a while depending on your system.
> ---
>
> [ --- ATTENTION! --- ]
> wxRuby3 requires some software packages to be installed before being able to continue building.
> If you like these can be automatically installed next (if you are building the source gem the
> software will be removed again after building finishes).
> Do you want to have the required software installed now? [yN] :
> ```

The initial message shown (between lines starting with '---' ) is indicative of what is going to happen depending 
on options passed to the setup command.<br>
Building the wxRuby3 native extensions and generating reference documentation will always happen.

#### Disable prompting for automatic install 

To prevent having the setup procedure asking consent the setup procedure can be started with the `--autoinstall` option 
like this:

```shell
wxruby setup --autoinstall
```

Note that on Linux that may still present a prompt in case the `sudo` command requires a password.

#### Prevent automatic installation of software requirements

To prevent the setup procedure from considering to automatically install (with or without prompting) any missing software
requirements the setup procedure can be started with the `--no-autoinstall` option like this: 

```shell
wxruby setup --no-autoinstall
```

The setup procedure will still analyze the system for available software requirements and if it finds any missing it
will end the procedure and show a message of what it found missing.

#### Force embedded wxWidgets installation

To prevent the setup procedure of using any system installed wxWidgets version the setup procedure can be started with 
the `--with-wxwin` option like this:

```shell
wxruby setup --with-wxwin
```

This will force the setup procedure to build and install an embedded wxWidgets version for wxRuby3.

#### Force embedded wxWidgets head installation

To force the setup procedure to build and install an embedded wxWidgets head (master) version the setup procedure can 
be started with the `--with-wxhead` option like this:

```shell
wxruby setup --with-wxhead
```

> **NOTE**<br>
> Although wxRuby3 endeavors to keep up to date with the wxWidgets master branch your mileage may vary depending on
> the development state of the wxWidgets master branch. You can check the latest results of the wxRuby3 CI master build 
> workflows of the [wxRuby3 Github Actions](https://github.com/mcorino/wxRuby3/actions) to get a feel of the current 
> integration state. 

#### Setup with user installed wxWidgets

In case of a (custom) user installation of wxWidgets the `--wxwin` (and optionally `--wxxml`) option(s) can be used to
start the setup procedure to build for this installation like this:

```shell
wxruby setup --wxwin=/my/custom/wxWidgets
```

If the wxWidgets installation also holds the doxygen generated XML interface specification files in the default location
(`docs/doxygen/out/xml`) these will be used to build the wxRuby3 extensions. If not, the setup procedure will create these
files itself (from a freshly cloned copy of the wxWidgets repository).<br>
If the XML files have been created in a non-standard location that can be passed on to the setup procedure like this:

```shell
wxruby setup --wxwin=/my/custom/wxWidgets --wxxml=/my/alternate/wxWidgets/xml
```

> **NOTE**<br>
> Please be aware that in case of building wxRuby3 for a user installation of wxWidgets the user is also 
> responsible for making sure the wxRuby3 extension library can find the wxWidgets libraries at runtime (normally this
> requires updating the standard shared library search path for the platform).

#### Setup with customized tool paths

If for whatever reason the required development tools `doxygen`, `swig` and/or `git` have been installed in a location
not in the standard executable search path the full path to these tools can be passed on the setup procedure using the
`--doxygen`, `--swig` and/or `--git` options like this:

```shell
wxruby setup --doxygen=/my/path/to/doxygen
```

#### Redirect log to customized path

The setup procedure will log full build results to a file setup.log at the location where the gem contents is stored.
If the setup fails the error message will display the log file location and by default if the setup succeeds the log 
file is deleted.<br>
To redirect the log file to be stored at an alternate location an not be deleted in any case the `--log` option can be
used like this:

```shell
wxruby setup --log=/my/log/folder
```

In this case the log file would be created as `/my/log/folder/setup.log`.

## Installing software requirements

As described, instead of having the wxRuby3 setup procedure install the software requirements automatically these can 
also be installed beforehand.

The following sections give some information how to accomplish that for the various supported platforms.

### Installing software requirements on Windows

On Windows these software requirements are only needed when **not** installing the binary gem.

#### Compiler

Download and install the [RubyInstaller MSYS2-Devkit](https://rubyinstaller.org/downloads/) which includes both Ruby
and a full set of development tools like GNU C++, make etc.

#### Doxygen

Download the Windows installer [here](https://doxygen.nl/download.html).

#### SWIG

Download the Windows archive [here](https://www.swig.org/download.html). 

#### Git

Any Windows compatible Git version will do like [this](https://gitforwindows.org/) one.

#### wxWidgets

See the information on the wxWidgets website [here](https://wxwidgets.org/downloads/). Download and install either
a binary installation compatible with the MingW64 compiler version available from the RubyInstaller MSYS2-Devkit 
installation (make sure to get this right or bad things will happen) or download a source package and build using the
compiler tools from the RubyInstaller MSYS2-Devkit installation. See [here](https://docs.wxwidgets.org/3.2/overview_install.html) for information about
building wxWidgets from source.

### Installing software requirements on MacOSX

#### Compiler

Install the XCode commandline tools using the command <code>sudo xcode-select --install</code>.

#### Doxygen

Depending on how you installed Ruby on your MacOS system use [Homebrew](https://brew.sh) with the command <code>brew install doxygen</code> 
or use [MacPorts](https://www.macports.org/) with the command <code>port install doxygen</code>.

#### SWIG

Depending on how you installed Ruby on your MacOS system use [Homebrew](https://brew.sh) with the command <code>brew install swig</code>
or use [MacPorts](https://www.macports.org/) with the command <code>port install swig</code>.

#### Git

Is included in the XCode commandline tools. 

#### wxWidgets

Either install a compatible wxWidgets version (>= 3.2) with the package manager of choice (Homebrew or MacPorts) if available
or download and build a source package from [here](https://wxwidgets.org/downloads/) (alternatively the wxWidgets Github 
repository could be cloned). See [here](https://docs.wxwidgets.org/3.2/overview_install.html) for information about
building wxWidgets from source.

### Installing software requirements on Linux

#### Compiler

Install the GNU C++ compiler and common development tools like 'make' using the system provided package management.

#### Patchelf

Install the patchelf tool using the system provided package management.

#### Doxygen

Install the doxygen tool using the system provided package management.

#### SWIG

Install the swig tool using the system provided package management.

#### Git

Install the git tool using the system provided package management.

#### wxWidgets

Either install a compatible wxWidgets version (>= 3.2) with the system provided package management if available
or download and build a source package from [here](https://wxwidgets.org/downloads/) (alternatively the wxWidgets Github
repository could be cloned). See [here](https://docs.wxwidgets.org/3.2/overview_install.html) for information about
building wxWidgets from source.

## Building from source

Checkout the wxRuby3 sources from [GitHub](https://github.com/mcorino/wxRuby3) or download and unpack a release package.

Requirements are the same as for installing the source gem. Gem dependencies are listed in the Gemfile in the root
of the wxRuby3 tree and should be installed by executing `bundle install`.<br>
To be able to generate HTML documentation the optional `:documentation` group should be included.<br>
To be able to run the Rake memory check task the optional `:develop` group should be included.

The wxRuby3 project provides a Rake based build system. Call `rake help` to get an overview of the available commands.
As mentioned there the `rake configure` command is required as the very first command. Call `rake configure[--help]` to
get a detailed overview of the options for this command.<br>
As with the source gem 3 options exist for the wxWidgets installation for which details can be specified to `rake configure`.  

When wxRuby3 has been configured the extensions can be build by calling the `rake build` command. The wxRuby3 build 
commands are executed using parallel task execution by default.

When the build has finished without errors the regression tests can be run by calling `rake test`.

After successfully building the wxRuby3 extension libraries (and possibly embedded wxWidgets libraries) a binary package
can be created by calling `rake binpkg`.

For more details concerning the wxRuby3 development strategy and build options see [here](TODO). 
