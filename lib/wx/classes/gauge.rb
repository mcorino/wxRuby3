# Gauge : presents a progress bar
#
# On the C++ side, the actual class name of wxGauge under Windows is
# wxGauge95. So when a Gauge is loaded from XRC, and we try to wrap the
# object in a ruby class by calling obj->ClassInfo()->ClassName(), it
# seeks for a ruby class (Wx::Gauge95) that doesn't exist (see
# swig/shared/get_ruby_object.i). 
#
# To fix this, make Wx::Gauge95 an alias.
if Wx::PLATFORM == 'WXMSW'
  Wx::Gauge95 = Wx::Gauge
end
