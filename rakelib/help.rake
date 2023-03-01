###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3
  HELP = <<__HELP_TXT

wxRuby3 Rake based build system
-------------------------------

This build system provides commands for building, testing and installing wxRuby3.
Building wxRuby3 requires a configure step to initialize build settings and check
all prerequisites for building the various variants of wxRuby3.

commands:

rake <rake-options> configure[--help]|[<configure options>]    # Configure wxRuby3 build settings
rake <rake-options> show             # Show current wxRuby3 build settings
rake <rake-options> build            # Build wxRuby3
rake <rake-options> clean            # Remove any temporary products.
rake <rake-options> clobber          # Remove any generated file.
rake <rake-options> help             # Provide help description about wxRuby3 build system
rake <rake-options> test             # Run all wxRuby3 tests
rake <rake-options> tests            # Run wxRuby3 tests
rake <rake-options> package          # Build all the packages
rake <rake-options> repackage        # Force a rebuild of the package files
rake <rake-options> clobber_package  # Remove package products
rake <rake-options> install[--help]|[<install options>] [NO_HARM=1]  # Install wxRuby3
rake <rake-options> uninstall[--help]|[<uninstall options>] [NO_HARM=1]  # Uninstall wxRuby3
rake <rake-options> gem              # Build wxRuby3 gem

__HELP_TXT
end

namespace :wxruby do
  task :help do
    puts WXRuby3::HELP
  end
end

desc 'Provide help description about wxRuby3 build system'
task :help => 'wxruby:help'
