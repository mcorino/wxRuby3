# rakeutil.rb
#   Copyright 2004-2005 by Kevin Smith
#   released under the MIT-style wxruby3 license

# This file is required by the main wxRuby rakefile.
# It contains stuff that I think should be included
# in the standard rake program

def force_mkdir(dir)
  if (!File.exists?(dir))
    Dir.mkdir(dir)
  end
end

def force_rmdir(dir)
  if (dir != '.' && dir != '..' && File.directory?(dir))
    rmdir(dir)
  end
end

def force_delete(f)
  if (f != '.' && f != '..' && File.exists?(f))
    rm(f)
  end
end

def delete_files_in(dir, mask='*')
  Dir[File.join(dir, mask)].each do |f|
    force_delete(f)
  end
end
