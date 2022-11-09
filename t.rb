require 'json'
require 'wx'
Wx::App.run do
  table = { 'Wx' => {}}
  Wx.constants.each do |c|
    the_const = Wx.const_get(c)
    if the_const.class == ::Module  # Enum submodule
      modname = c.to_s
      mod = Wx.const_get(c)
      table[modname] = {}
      mod.constants.each do |ec|
        e_const = mod.const_get(ec)
        table[modname][ec.to_s] = { type: e_const.class.name.split('::').last, value: e_const }
      end
    else
      table['Wx'][c.to_s] = { type: the_const.class.name.split('::').last, value: the_const } unless ::Class === the_const || c == :THE_APP
    end
  end
  STDERR.puts '* DUMPING CONSTANTS TABLE'
  STDOUT.puts JSON.dump(table)
end
