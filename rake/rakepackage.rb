require 'rubygems'
require 'rake/packagetask'

# This file adds support for five Rake targets
# Two important ones:
# :gem     - build a binary wxruby gem for current platform
# :package - build a platfrom-neutral source tarball
task :version do
  if WXRUBY_VERSION.empty?
    raise "Cannot build a package without a version being specified\n" +
          "Create a version by running rake with WXRUBY_VERSION=x.x.x"
  end
end

$base_gemspec = Gem::Specification.new do | spec |
  spec.name = 'wxruby'
  if RUBY_VERSION >= "1.9.0"
    spec.name << "-ruby19"
  end

  spec.version = "#{WXRUBY_VERSION}"

  spec.require_path = 'lib'
  spec.summary  = 'Ruby interface to the wxWidgets GUI library'
  spec.author   = 'wxRuby development team'
  spec.homepage = 'http://wxruby.rubyforge.org'

  spec.rubyforge_project = 'wxruby'
  spec.description = <<-DESC
  wxRuby allows the creation of graphical user interface (GUI)
  applications via the wxWidgets library. wxRuby provides native-style
  GUI windows, dialogs and controls on platforms including Windows, OS X
  and Linux.
  DESC

  spec.require_path = 'lib'
  # Platform specific binaries are added in later
  spec.files        = FileList[ 'lib/**/*' ].to_a +
                      FileList[ 'art/**/*' ].to_a +
                      FileList[ 'samples/**/*' ].to_a +
                      FileList[ 'README', 'INSTALL', 'LICENSE' ].to_a

  spec.has_rdoc = false
end

def create_release_tasks
  create_gem_tasks
  create_package_tasks
end

# creates 'gem', 'gem_osx', 'gem_linux' and 'gem_mswin' tasks
def create_gem_tasks
  # basic binary gem task for current platform
  desc "Build a binary RubyGem for the current platform"
  task :gem => [ :default, :version ] do
    this_gemspec = $base_gemspec.dup()    
    this_gemspec.instance_eval do       
      self.platform = Gem::Platform::CURRENT
      self.files += [ TARGET_LIB ]
      # If building on OS X, test for splitting OS universal gem into two 
      if self.platform.os == 'darwin' and 
         self.platform.cpu == 'universal' and 
         $osx_split_gem_name
        self.platform.cpu = $osx_split_gem_name
      end
    end
    Gem::Builder.new(this_gemspec).build
  end
end

def create_package_tasks
  Rake::PackageTask.new('wxruby', WXRUBY_VERSION) do | p_task |
    p_task.need_tar_gz = true
    pkg_files = p_task.package_files
    pkg_files.include('README', 'INSTALL', 'LICENSE', 'ChangeLog', 'rakefile')
    pkg_files.include('lib/**/*.rb')
    pkg_files.include('swig/**/*')
    pkg_files.include('tests/**/*')
    pkg_files.include('rake/**/*')
    pkg_files.include('art/**/*')
    pkg_files.include('samples/**/*')
    pkg_files.include('doc/lib/**/*.rb')
    pkg_files.include('doc/**/*.txtl', 'doc/wxruby.css')
  end
end
task :package => :version

desc "Creates 3 gems for Mac OS X: universal, powerpc, i686."
task :osx_all_gems do
  if !$macosx
    puts "This task only works on Mac OS X."
    exit
  end
  
  # Figure out OS Version to run lipo correctly
  # on 10.4 the ppc part of a universal binary is called ppc
  # on 10.5 the ppc part is called ppc7400
  data = %x{system_profiler SPSoftwareDataType}
  if data.include?('Mac OS X 10.5')
    lipo_ppc = 'ppc7400'
  else
    lipo_ppc = 'ppc'
  end
  
  gem_name = 'wxruby'
  default_full_gem_name = "#{gem_name}-#{WXRUBY_VERSION}-universal-darwin.gem"
  
  gem_task = Rake::Task['gem']
  gem_task.application.handle_options()
  
  if File.exists?(default_full_gem_name)==false
    puts ""
    puts "The universal gem (#{default_full_gem_name}) must exist before running this task. Creating..."
    gem_task.execute
  end
  
  ext = GEM_PLATFORMS['osx'][1]
  tmp_dir = "tmp_osx_lib"
  
  #save the current universal build
  if File.exists?(tmp_dir)==false
    sh "mkdir #{tmp_dir}"
  end
  sh "mv #{default_full_gem_name} #{tmp_dir}/"
  sh "mv lib/wxruby3#{ext} #{tmp_dir}/"
  
  gem_task = Rake::Task['gem']
  gem_task.application.handle_options()
  
  #create the ppc version of library and build gem
  puts ""
  create_osx_platform_gem(default_full_gem_name,tmp_dir,ext,gem_task,lipo_ppc)

  #remove the stripped lib now that gem is made
  sh "rm lib/wxruby3#{ext}"

  #create the i386 version of library and build gem
  puts ""
  create_osx_platform_gem(default_full_gem_name,tmp_dir,ext,gem_task,"i386")

  #move back the universal gem
  sh "rm lib/wxruby3#{ext}"
  sh "mv #{tmp_dir}/wxruby3#{ext} lib/"
  sh "mv #{tmp_dir}/#{default_full_gem_name} ."

  sh "rmdir #{tmp_dir}"
end

def create_osx_platform_gem(gem_name,tmp_dir,lib_ext,gem_build_task,platform="ppc")
  if platform.include?("ppc")
    cpu = 'powerpc'
  else
    cpu = 'i686'
  end
  
  $osx_split_gem_name = "#{cpu}-darwin"
  puts "Creating GEM for Mac OS X (#{platform})"
  sh "lipo #{tmp_dir}/wxruby3#{lib_ext} -thin #{platform} -output lib/wxruby3#{lib_ext}"
  sh "lipo -info lib/wxruby3#{lib_ext}"  
  gem_build_task.execute
end
