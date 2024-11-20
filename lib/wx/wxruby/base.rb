# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# wxruby command handler base

require 'optparse'
require "rbconfig"

module WxRuby

  RUBY = ENV["RUBY"] || File.join(
    RbConfig::CONFIG["bindir"],
    RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]).sub(/.*\s.*/m, '"\&"')

  module Commands

    class << self

      def commands
        @commands ||= ::Hash.new do |hash, key|
          STDERR.puts "Unknown command #{key} specified."
          exit(127)
        end
      end
      private :commands

      def setup_done?
        File.exist?(File.join(WxRuby::ROOT, 'ext', 'wxruby.setup.done'))
      end

      def options
        @options ||= {
          :verbose => false
        }
      end

      def register(cmdid, cmdhandler)
        commands[cmdid.to_s] = case
                               when Proc === cmdhandler || Method === cmdhandler
                                 cmdhandler
                               when cmdhandler.respond_to?(:run)
                                 Proc.new { |args| cmdhandler.run(args) }
                               else
                                 raise RuntimeError, "Invalid wxruby command handler : #{cmdhandler}"
                               end
      end

      def describe_all
        puts "    wxruby commands:"
        commands.each do |id, cmd|
          puts
          puts cmd.call(:describe)
        end
        puts
      end

      def show_version
        system(%Q[#{RUBY} -r wx -e 'puts "wxRuby3 v\#{Wx::WXRUBY_VERSION} (wxWidgets v\#{Wx::WXWIDGETS_VERSION})"' 2> /dev/null])
      end

      def run(cmdid, args)
        commands[cmdid.to_s].call(args)
      end

      def parse_args(args)
        opts = OptionParser.new
        opts.banner = "Usage: wxruby [global options] COMMAND [arguments]\n\n" +
            "    COMMAND\t\t\t\tSpecifies wxruby command to execute."
        opts.separator ''
        opts.on('-v', '--verbose',
                'Show verbose output') { |_| ::WxRuby::Commands.options[:verbose] = true }
        opts.on('-V', '--version',
                'Show versions.') { |_| show_version } if setup_done?
        opts.on('-h', '--help',
                 'Show this message.') do |_|
          puts opts
          puts
          describe_all
          exit(0)
        end
        opts.order!(args) rescue ($stderr.puts $!.message; exit(127))
      end
    end
  end

  def self.run(argv = ARGV)
    # parse global options (upto first command)
    argv = WxRuby::Commands.parse_args(argv)
    WxRuby::Commands.run(argv.shift, argv) unless argv.empty?
  end
end

Dir[File.join(__dir__, 'cmd', '*.rb')].each do |file|
  require file
end
