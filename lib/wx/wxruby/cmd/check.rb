# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby check command handler
#--------------------------------------------------------------------

require 'fileutils'
require 'plat4m'

module WxRuby
  module Commands

    class Check

      LOAD_ERRORS = {
        linux: /cannot\s+open\s+shared\s+object/i,
        darwin: /library\s+not\s+loaded/i,
        windows: /specified\s+module\s+could\s+not\s+be\s+found/i
      }

      DESC = 'Run wxRuby3 runtime readiness check.'

      def self.description
        "    check -h|[options]\t\t\t#{DESC}"
      end

      def self.options
        Commands.options['check'] ||= { verbose: Commands.options[:verbose] }
      end

      def self.parse_args(args)
        opts = OptionParser.new
        opts.banner = "#{DESC}\n\nUsage: wxruby check -h|--help OR wxruby check [options]\n\n" +
                      "Returns:\n"+
                      "   0   if wxRuby3 is ready to run\n"+
                      "   1   if wxRuby3 does not seem to be built yet\n"+
                      "   2   if wxRuby3 has problems loading extension libraries\n"+
                      "   3   if an unexpected Ruby error occurred\n\n"+
                      "Unless '-q|--quiet' has been specified a description of the possible problem cause will\n"+
                      "be shown on failure.\n\n"
        opts.separator ''
        opts.on('-q', '--quiet',
                "Do not show problem analysis messages on failures.") do |v|
          Check.options[:quiet] = true
          Check.options[:verbose] = false
        end
        opts.on('-v', '--verbose',
                'Show verbose output') do |v|
          Check.options[:verbose] = true
          Check.options[:quiet] = false
        end
        opts.on('-h', '--help',
                'Show this message.') do |v|
          puts opts
          puts
          exit(0)
        end
        opts.parse!(args)
      end

      def self.show_error(msg)
        $stderr.puts(msg) unless options[:quiet]
      end

      def self.show_log(msg)
        $stdout.puts(msg) if options[:verbose]
      end

      def self.run(argv)
        return description if argv == :describe

        parse_args(argv)

        show_log('Checking build (or binary package installation) completion...')
        # check if the binary setup (packages or built) has been completed successfully
        unless Commands.setup_done?
          $stderr.puts <<~__INFO_TXT

            wxRuby3 requires the post-install setup cmd to be run to build and finish installing
            the required runtime binaries. Execute the command like:

            $ wxruby setup

            To see the available options for the command execute:

            $ wxruby setup -h
 
          __INFO_TXT
          exit(1)
        end

        # check runtime
        show_log('Attempting to load wxRuby3 libraries...')
        sysinfo = Plat4m.current
        begin
          require 'wx'
        rescue LoadError => ex
          if ex.message =~ LOAD_ERRORS[sysinfo.os.id]
            # error loading shared libraries
            show_log("Captured LoadError: #{ex.message}")
            # check if wxWidgets libs can be located
            show_log('Checking wxWidgets availability...')
            wx_found = if Dir[File.join(WxRuby::ROOT, 'ext', "*.#{RbConfig::CONFIG['SOEXT']}")].empty?
                         # no embedded wxWidgets -> if system installed than 'wx-config' should be in the path
                         if system("wx-config --version>#{sysinfo.dev_null} 2>&1")
                           true # system installed
                         else
                           # no system installed wxWidgets
                           # check the system dependent load paths if any wxWidgets libs can be found
                           case sysinfo.os.id
                           when :linux
                             (ENV['LD_LIBRARY_PATH']||'').split(':').any? { |p| !Dir[File.join(p, 'libwx_base*.so')].empty? }
                           when :darwin
                             (ENV['DYLD_LIBRARY_PATH']||'').split(':').any? { |p| !Dir[File.join(p, 'libwx_base*.dylib')].empty? }
                           when :windows
                             (ENV['PATH']||'').split(';').any? { |p| !Dir[File.join(p, 'wxbase*.dll')].empty? }
                           else
                             true # do not know how to search so assume wxWidgets found
                           end
                         end
                       else
                         true # embedded wxWidgets
                       end
            if wx_found
              show_log('wxWidgets found')
              show_error <<~__INFO_TXT

                The runtime environment of this system seems to be missing some required libraries for
                executing wxRuby3 apps.
                Please be aware wxRuby3 requires a properly configured GUI based system to function.
                See the documentation for more information on the required runtime environment.   
     
                __INFO_TXT
            else
              show_log('NO wxWidgets found')
              show_error <<~__INFO_TXT

                It seems wxRuby3 is not able to load any of the required wxWidgets libraries it was built
                for.
                Please make sure these (shared) libraries are available in the appropriate search path
                for this system. 
     
                __INFO_TXT
            end
          else
            show_error <<~__INFO_TXT

              There is an unexpected problem loading the wxRuby3 extension libraries.
              Please check the problem report below for a probable cause analysis. If you have reason
              to suspect a bug to be the cause of this problem please file an issue at Github and attach 
              the problem report. 

              #{ex.message}
              #{ex.backtrace.join("\n")}
   
              __INFO_TXT
          end
          exit(2)
        rescue Exception => ex
          show_log("Captured Exception: #{ex.message}")
          show_error <<~__INFO_TXT

            There is an unexpected problem loading the wxRuby3 libraries.
            Please check the problem report below for a probable cause analysis. If you have reason
            to suspect a bug to be the cause of this problem please file an issue at Github and attach 
            the problem report. 

            #{ex.message}
            #{ex.backtrace.join("\n")}
 
            __INFO_TXT
          exit(3)
        end
      end

    end

    self.register('check', Check)

  end
end
