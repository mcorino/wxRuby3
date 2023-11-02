
require 'set'

ROOT = File.dirname(__dir__)

module Tool

  SWIG_TYPES_USED = Set.new
  SWIG_TYPES_USED_FILES = {}
  SWIG_TYPES_WRAPPED = Set.new

  class << self

    def errors?
      !!@errors
    end

    def set_errors(f = true)
      @errors = f
    end

    def scan_sources
      Dir[File.join(ROOT, 'ext', 'wxruby3', 'src', '*.cpp')].each do |p|

        IO.readlines(p).each do |ln|

          case ln
          when /SWIG_ConvertPtr\([^,]+,\s*[^,]+,\s*(SWIGTYPE_p_\w+),/
            SWIG_TYPES_USED << $1
            (SWIG_TYPES_USED_FILES[$1] ||= ::Set.new) << File.basename(p)
          when /SWIG_NewPointerObj\([^,]+,\s*(SWIGTYPE_p_\w+),/
            # exclude lines from SWIG OUTPUT mappings
            type_str = $1
            unless /SWIG_Ruby_AppendOutput\(/ =~ ln
              SWIG_TYPES_USED << type_str
              (SWIG_TYPES_USED_FILES[type_str] ||= ::Set.new) << File.basename(p)
            end
          when /VALUE\s+vresult\s+=\s+SWIG_NewClassInstance\(self,\s*(SWIGTYPE_p_\w+)\);/
            SWIG_TYPES_USED << $1
            (SWIG_TYPES_USED_FILES[$1] ||= ::Set.new) << File.basename(p)
          when /SwigClassWxBitmap.klass\s+=\s+rb_define_class_under\(.*\(\(swig_class\s+\*\)\s*(SWIGTYPE_p_\w+)->clientdata\)->klass\);/
            SWIG_TYPES_USED << $1
            (SWIG_TYPES_USED_FILES[$1] ||= ::Set.new) << File.basename(p)
          when /\A\s+SWIG_TypeClientData\((SWIGTYPE_p_\w+),/
            if SWIG_TYPES_WRAPPED.include?($1)
              STDERR.puts "*** ERROR: SWIG type #{$1} defined multiple times."
              set_errors
            else
              SWIG_TYPES_WRAPPED << $1
            end
          end

        end

      end
    end

    def check_types(verbose)
      un_wrapped = SWIG_TYPES_USED - SWIG_TYPES_WRAPPED
      un_used = SWIG_TYPES_WRAPPED - SWIG_TYPES_USED

      unless un_wrapped.empty?
        set_errors
        STDERR.puts "ERROR: The following types are converted/created without matching wrapper classes defined:"
        un_wrapped.each { |s| STDERR.puts "\t#{'%40s' % s} in #{SWIG_TYPES_USED_FILES[s].to_a}" }
        STDERR.puts
      end

      unless un_used.empty? || !verbose
        STDOUT.puts "INFO: The following types have wrapper classes defined not used in wrapper code:"
        un_used.each { |s| STDOUT.puts "\t#{s}" }
        STDOUT.puts
      end
    end

  end

  def self.run(verbose)
    scan_sources

    check_types(verbose)
  end

end

Tool.run(ARGV.size==1 && ARGV[0]=='-v')

exit(1) if Tool.errors?
