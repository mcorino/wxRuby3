# renamer.rb
#   Copyright 2004-2005 by Kevin Smith
#   released under the MIT-style wxruby2 license

#   This script post-processes the SWIG output
#   to rename methods to ruby_naming_conventions

camelCaseFile = ARGV[0]+".old"
File.rename(ARGV[0], camelCaseFile)

this_module = File.basename(ARGV[0])
class String
  ACRONYMS = /([A-Z0-9_]{2,})(?=[A-Z][a-z])/
  CAPITALS = /([a-z])(?=[A-Z0-9])/
  NUMBERS  = /(\d+)(?=[A-Za-z_])/

	# retrived from inflector.rb from active_support
  def underscore()
    gsub!(/::/, '/').
    gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub!(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase!
  end
  
  def un_camelcase(word_sep = '_')
    dup.un_camelcase!(word_sep)
  end

  def un_camelcase!(word_sep = '_')
=begin
    gsub!(ACRONYMS) { $1 + word_sep }
    gsub!(CAPITALS) { $1 + word_sep }
    gsub!(NUMBERS)  { $1 + word_sep }
    downcase!
=end
    gsub!(/::/, '/')
    gsub!(/([A-Z]+)([A-Z][a-z])/,"\\1#{word_sep}\\2")
    gsub!(/([a-z\d])([A-Z])/,"\\1#{word_sep}\\2")
    tr("-","#{word_sep}")
    downcase!
    self
  end

  def camelcase(word_sep = '_')
    dup.camelcase!(word_sep)
  end

  def camelcase!(word_sep = '_')
    gsub!(/(?:\A|#{word_sep})([a-z])/) { $1.upcase }
  end

  # True if +self+ appears to be a camelcased word
  def camelcase?()
    self =~ /^(?:[A-Z][a-z]+){2,}/
  end
end

def fix_define_method(line)
    re = Regexp.new('".*"')
    match = re.match(line)
    if(match)
        quoted_method_name = match[0]
        return line if quoted_method_name == '"THE_APP"'
        method_name = quoted_method_name[1..-2]
        new_method_name = '"%s"' % strip_wx(method_name.un_camelcase)
        line[quoted_method_name] = new_method_name
        #puts(line)
    end
    return line
end

def strip_wx(class_name) 
  return class_name.sub(/^wx_?/i,'')
end

def fix_quoted_wx(line)
    match = /"(.*)"/.match(line)
    if(match)
      #puts("Stripping #{line}")
      quoted_wx_name = match[1]
      wx_name = quoted_wx_name.sub(/^wx_?/i,'')
      line[match[0]] = '"' + wx_name + '"'
      #puts(line)
    end
    return line
end

#
# NSK - SWIG handles some constants the same way as methods.
# Use the case of the value to figure out which naming scheme to use
# (Uppercase ones are constant, Mixed case are methods)
#
def is_constant_or_method(line)
    re = Regexp.new('".*"')
    match = re.match(line)
    if(match)
	#puts("Stripping #{line}")
        quoted_wx_name = match[0]
        wx_name = quoted_wx_name[1..-2]
	swx_name = strip_wx(wx_name)
        if (swx_name == swx_name.upcase)
	    return fix_quoted_wx(line)
	else
            return fix_define_method(line)
	end
        
    end
    return line
end

File.open(ARGV[0], "w") do | out |
    File.foreach(camelCaseFile) do | line |
        if(line.index("rb_define_method") || line.index("rb_intern"))
            line = fix_define_method(line)
        end
        if(line.index("rb_define_class_under"))
            line = fix_quoted_wx(line)
        end
        if(line.index("rb_define_const"))
            line = fix_quoted_wx(line)
        end
        if(line.index("rb_define_singleton_method"))
            line = is_constant_or_method(line)
        end
        if(line.index("rb_define_module_function"))
            line = fix_define_method(line)
        end
        out.puts(line)
    end
end

File.delete(camelCaseFile)
