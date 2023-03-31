<!--
# @markup markdown
# @title 1. wxRuby Modules
-->

# 1. wxRuby Modules

## Introduction

Previous wxRuby implementations provided a single toplevel module approach for the wxRuby API with a single loading
option. Including `require 'wx'` in any application would load the entire wxRuby library and make all classes, module
methods and constants available under the `Wx` toplevel module.

The wxRuby3 project however implements a more modular approach similar to wxWidgets itself which distributes
implementations over various sub-modules. These sub-modules can be loaded separately to provide more control.
The core module still provides the toplevel `Wx` namespace and all classes and constants declared in that namespace.
All other modules add to that (and **all** require the core module).

## Loading and Naming scopes

The *old* **all-in-one** approach in still supported with the wxRuby3 project. Using

```ruby
require 'wx'
```

will load all wxRuby API modules and make all classes and constants available from the `Wx` toplevel module. This 
*global* naming scope approach does **not** extend to class or module methods (including dialog *functors*; see 
[here](03_dialogs.md) for more information).
 
The *new* sub-module approach however allows for loading only part(s) of the wxRuby library like:

```ruby
require 'wx/core' # load wxRuby core Wx module
require 'wx/grid' # load wxRuby Wx::GRID module - provides Grid control
require 'wx/rtc'  # load wxRuby Wx::RTC module - provides RichText control 
```

However, when loading the library like this scoping rules change by default. Specifically the constants and classes
from the loaded sub-modules will **not** be accessible from the `Wx` scope anymore (like `Wx::Grid`) but must instead be
explicitly scoped from the sub-module (like `Wx::GRID::Grid`).

It is possible to revert the 'global scope' resolution behaviour by setting the toplevel constant `WX_GLOBAL_CONSTANTS` to
`true` before the require statements like:

```ruby
WX_GLOBAL_CONSTANTS=true
require 'wx/core' # load wxRuby core Wx module
require 'wx/grid' # load wxRuby Wx::GRID module - provides Grid control
require 'wx/rtc'  # load wxRuby Wx::RTC module - provides RichText control 
```

## Modules

Currently the following modules have been implemented.

### Core

The core wxRuby package providing the toplevel `Wx` module.
This package includes basic classes like:

- `Wx::Object`
- `Wx::EvtHandler`
- `Wx::Event`
- `Wx::CommandEvent`
- `Wx::App`
- `Wx::Window`
- `Wx::NonOwnedWindow`
- `Wx::ToplevelWindow`
- `Wx::Frame`
- `Wx::Dialog`

as well as most common window classes, control/widget classes, event classes, constant and enum definitions
and global functions not part of any of the other packages.

### AUI - Advanced User Interface controls and related classes

The wxRuby AUI package providing the `Wx::AUI` module.
This package includes all classes, constants and enum definitions that are considered part of the 
wxWidgets AUI framework like:

- `Wx::AUI::AuiManager`
- `Wx::AUI::AuiMDIParentFrame`
- `Wx::AUI::AuiMDIChildFrame`
- `Wx::AUI::AuiMDIClientWindow`
- etc

### GRID - Grid control and related classes

The wxRuby GRID package providing the `Wx::GRID` module.
This package includes all classes, constants and enum definitions that are associated with the
wxWidgets wxGrid control like:

- `Wx::GRID::Grid`
- `Wx::GRID::GridTableBase`
- `Wx::GRID::GridCellEditor`
- `Wx::GRID::GridCellRenderer`
- `Wx::GRID::GridEvent`
- etc

### HTML - Html framework classes

The wxRuby HTML package providing the `Wx::HTML` module.
This package includes all classes, constants and enum definitions that are considered part of the
wxWidgets Html framework like:

- `Wx::HTML::HtmlWindow`
- `Wx::HTML::HtmlHelpWindow`
- `Wx::HTML::HtmlHelpFrame`
- `Wx::HTML::HtmlHelpController`
- etc

### PG - PropertyGrid control and related classes

The wxRuby PG package providing the `Wx::PG` module.
This package includes all classes, constants and enum definitions that are associated with the
wxWidgets wxPropertyGrid control like:

- `Wx::PG::PropertyGrid`
- `Wx::PG::PropertyGridManager`
- `Wx::PG::PGCell`
- `Wx::PG::PGProperty`
- `Wx::PG::PropertyGridEvent`
- etc

### PRT - Printing framework classes

The wxRuby PRT package providing the `Wx::PRT` module.
This package includes all classes, constants and enum definitions that are considered part of the
wxWidgets Printing framework like:

- `Wx::PRT::PreviewFrame`
- `Wx::PRT::Printer`
- `Wx::PRT::PrinterDC`
- `Wx::PRT::PrintDialog`
- etc

### RBN - Ribbon framework classes

The wxRuby RBN package providing the `Wx::RBN` module.
This package includes all classes, constants and enum definitions that are considered part of the
wxWidgets Ribbon framework like:

- `Wx::RBN::RibbonControl`
- `Wx::RBN::RibbonGallery`
- `Wx::RBN::RibbonPanel`
- `Wx::RBN::RibbonPage`
- `Wx::RBN::RibbonBar`
- etc

### RTC - RichText control and related classes

The wxRuby RTC package providing the `Wx::RTC` module.
This package includes all classes, constants and enum definitions that are associated with the
wxWidgets wxRichTextCtrl control like:

- `Wx::RTC::RichTextCtrl`
- `Wx::RTC::RichTextEvent`
- `Wx::RTC::RichTextBuffer`
- etc

### STC - StyledText control and related classes

The wxRuby STC package providing the `Wx::STC` module.
This package includes all classes, constants and enum definitions that are associated with the
wxWidgets wxStyledTextCtrl control (Scintilla integration) like:

- `Wx::STC::StyledTextCtrl`
- `Wx::STC::StyledTextEvent`

## Feature dependencies

Availability of wxRuby packages is controlled by the wxWidget feature switches. The default build options will
include all platform supported features but in case of building wxRuby for customized wxWidgets builds the wxRuby3
build procedures will take the wxWidgets settings into account.

If for instance wxWidgets was built without Html support (using the configure `--disable-html` switch) the wxRuby
HTML package will not be available as well.
This behavior is controlled by the `wxUSE_xxx` macros that wxRuby extracts from the wxWidgets `wx/setup.h` file.
