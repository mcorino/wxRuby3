###
# wxRuby3 rake gem support
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'rubygems'
require 'rubygems/package'
begin
  require 'rubygems/builder'
rescue LoadError
end

require_relative './lib/config'

module WXRuby3

  module Gem

    class << self
      def wxwin_shlibs
        unless @wxwin_shlibs
          @wxwin_shlibs = Rake::FileList.new
          # include wxWidgets shared libraries we linked with
          wx_libs = WXRuby3.config.wx_libs.split(' ')
          wx_libs.select { |s| s.start_with?('-L') }.each do |libdir|
            libdir = libdir[2..libdir.size]
            libdir = File.join(File.dirname(libdir), 'bin') if WXRuby3.config.windows?
            wx_libs.select { |s| s.start_with?('-l') }.each do |lib|
              lib = lib[2..lib.size]
              if WXRuby3.config.windows?
                # match only wxWidgets libraries
                if (m = /\Awx_([a-z]+)(_[a-z]+)?-(.*)/.match(lib))
                  # translate lib name to shlib name
                  grp_id = m[1]
                  lib_id = m[2]
                  ver = m[3].sub('.', '')
                  lib = "wx#{grp_id.sub(/u\Z/, '')}#{ver}u#{lib_id}"
                  @wxwin_shlibs.include File.join(libdir, "#{lib}*.#{WXRuby3.config.dll_mask}")
                end
              else
                # match only wxWidgets libraries
                if /\Awx_([a-z]+)(_[a-z]+)?-(.*)/.match(lib)
                  @wxwin_shlibs.include File.join(libdir, "lib#{lib}*.#{WXRuby3.config.dll_mask}")
                end
              end
            end
          end
        end
        @wxwin_shlibs
      end
    end

    def self.manifest(gemtype = :src)
      # create MANIFEST list with included files
      manifest = Rake::FileList.new
      manifest.include %w[bin/*] # *nix executables in bin/
      manifest.exclude %w[bin/*.bat] unless WXRuby3.config.windows?
      manifest.include %w[lib/**/* samples/**/* tests/**/* art/**/*]
      if gemtype == :bin
        if WXRuby3.config.get_config('with-wxwin')
          manifest.include "ext/*.#{WXRuby3.config.dll_mask}"
        end
        manifest.include 'ext/mkrf_conf_bingem.rb'
      else
        manifest.exclude "lib/*.#{WXRuby3.config.dll_mask}"
        manifest.include 'ext/wxruby3/swig/**/*'
        manifest.exclude 'ext/wxruby3/swig/classes/**/*'
        manifest.include 'ext/mkrf_conf_srcgem.rb'
        manifest.include 'rakelib/**/*'
        manifest.exclude %w[rakefile/install.* rakelib/help.* rakelib/package.*]
      end
      manifest.include %w{LICENSE README.md CREDITS.md}
      manifest
    end

    def self.define_spec(name, version, gemtype = :src, &block)
      gemspec = ::Gem::Specification.new(name, version)
      if gemtype == :bin
        platform = ::Gem::Platform.local.to_s
        platform << "-#{WXRuby3::Config.rb_ver_major}.#{WXRuby3::Config.rb_ver_minor}"
        if WXRuby3.config.get_config('with-wxwin')
          platform << "-#{WXRuby3.config.wx_version}"
        end
        gemspec.platform = platform
      end
      gemspec.required_rubygems_version = ::Gem::Requirement.new(">= 0") if gemspec.respond_to? :required_rubygems_version=
      block.call(gemspec) if block_given?
      gemspec
    end

    def self.gem_name(name, version, gemtype = :src)
      define_spec(name, version, gemtype).full_name
    end

    def self.gem_file(name, version, gemtype = :src)
      File.join('pkg', "#{WXRuby3::Gem.gem_name(name, version, gemtype)}.gem")
    end

    def self.build_gem(gemspec)
      if defined?(::Gem::Package) && ::Gem::Package.respond_to?(:build)
        gem_file_name = ::Gem::Package.build(gemspec)
      else
        gem_file_name = ::Gem::Builder.new(gemspec).build
      end

      FileUtils.mkdir_p('pkg')

      FileUtils.mv(gem_file_name, 'pkg')
    end

    # unless defined?(JRUBY_VERSION) || R2CORBA::Config.is_win32
    #   def self.patch_extlib_rpath
    #     if R2CORBA::Config.is_osx
    #       # TODO
    #     else
    #       rpath = "#{File.expand_path('ext')}:#{get_config('libdir')}"
    #       Dir['ext/*.so'].each do |extlib|
    #         unless Rake.sh("#{R2CORBA::Config.rpath_patch} '#{rpath}' #{extlib}")
    #           raise 'Failed to patch RPATH for #{extlib}'
    #         end
    #       end
    #     end
    #   end
    # end

  end

end
