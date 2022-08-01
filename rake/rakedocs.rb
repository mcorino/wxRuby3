# Tasks for rendering the documentation
# 
# Currently the basic steps to render the HTML documentation are:
#  > rake textile_docs WXWIN=/path/to/base/wxwidgets/source/dir
#  > rake html_docs
# 
# The first step extracts class documentation files from the wxwidgets
# latex documentation. These are output in Textile format, to the
# directory doc/textile. Note that there isn't a one-to-one mapping 
# of latex source files to classes.
# 
# The second step renders these Textile files to HTML, which is output
# to the directory doc/html. It also renders the index page (which is
# based on a static Textile file, doc/textile/index.txtl), and copies
# the wxruby .css into the directory.

CVS_BASE_DIR = File.expand_path('.')

$LOAD_PATH.push( File.join(CVS_BASE_DIR, 'doc', 'lib') )

require 'wxlatex_parser'
require 'html_generator'

DOC_DIR = File.join(CVS_BASE_DIR, 'doc')
DOC_OUTPUT_DIR = File.join(DOC_DIR, 'html')
DOC_TEXTILE_DIR = File.join(DOC_DIR, 'textile')

desc 'Build a complete set of html documentation in doc/html'
task :html_docs => [ 'doc/html/index.html', 
                     :html_class_docs, 
                     'doc/html/wxruby.css' ]

# returns all the HTML output targets
def all_class_docs
  docs = Dir.glob( File.join(DOC_TEXTILE_DIR, '*.txtl') )
  docs.delete_if { | doc | doc =~ /index\.txtl$/ }
  docs.collect! { | doc | doc.gsub(/(?:textile|txtl$)/, 'html') }
  docs
end

# Pattern mapping HTML outputs in doc/html to textile source files in
# doc/textile - used in task below.
txtl_src = lambda do | tn |
  tn.sub(/html\/(\w+)\.html$/) {  "textile/#{$1}.txtl" }
end

# How to create class
desc 'Create a HTML class reference page from a textile source'
rule '.html' => [ txtl_src ] do | t |
  if not File.exists?( DOC_OUTPUT_DIR )
    File.mkdir(DOC_OUTPUT_DIR)
  end
  puts "Rendering #{t.name}"
  gen = ClassFileHTMLGenerator.new(t.source)
  gen.output(t.name)
end

desc 'Build HTML reference docs for all WxWidgets classes'
task :html_class_docs => all_class_docs

# build the index page for the documentation - note that this task uses
# a different HTMLOutputter which strips out references to WxWidgets
# classes which are not yet ported to WxRuby. The Textile source file
# for this task (doc/textile/index.txtl) is hand-written, not generated
# from Textile sources.
file 'doc/html/index.html' => [ 'doc/textile/index.txtl' ] do | t | 
  if not File.exists?( DOC_OUTPUT_DIR )
    Dir.mkdir( DOC_OUTPUT_DIR )
  end
  puts "Rendering #{t.name}"
  src_file = File.join(DOC_TEXTILE_DIR, 'index.txtl')
  gen = IndexPageGenerator.new(src_file)
  gen.output(t.name)
end

# Copy the wxruby.css file into the HTML output directory
file 'doc/html/wxruby.css' => 'doc/wxruby.css' do
  cp 'doc/wxruby.css', 'doc/html/wxruby.css'
end

WXWIN = ENV['WXWIN']
desc 'Make class doc sources in doc/textile from WxWidgets Latex docs'
task :textile_docs do
  if not WXWIN
    raise "WXWIN environment variable not set; point to Wx sources base dir"
  end
  
  all_latex_srcs = File.join(File.expand_path(WXWIN), 
                             'docs', 'latex', 'wx', '*.tex')
  Dir.glob(all_latex_srcs).each do | src |
    puts "Converting #{src}"
    wxlp = WxWLatexClassParser.new_from_file(src, DOC_TEXTILE_DIR)
    wxlp.parse()
  end
end

doc_zip_package = "doc/wxruby-docs-#{WXRUBY_VERSION}.zip"

file doc_zip_package => [ :html_docs ] do | t |
  sh "zip #{doc_zip_package} doc/html/*.*"
end
desc "Zip up the HTML documentation"
task :doc_zip => [ doc_zip_package ]

doc_tar_gz_package = "doc/wxruby-docs-#{WXRUBY_VERSION}.tar.gz"
file doc_tar_gz_package  => [ :html_docs ] do | t |
  sh "tar -zcvf #{doc_tar_gz_package} doc/html/*.*"
end
desc "Tarball the HTML documentation"
task :doc_tar_gz => [ doc_tar_gz_package ]

# set the rubyforge username for publishing to the website
RUBYFORGE_USER = ENV['RUBYFORGE_USER']

desc 'Publish rendered docs and sources to the wxRuby website, using scp'
task :publish_docs => [ :html_docs ] do | t | 
  if not RUBYFORGE_USER
    raise 'Must specify RUBYFORGE_USER to publish documents'
  end
  # the location we are publishing to
  dest = "#{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/wxruby/doc/"
  sh "scp doc/html/*.html #{dest}"
  sh "scp doc/html/*.css #{dest}"
  sh "scp doc/textile/*.txtl #{dest}"
end
