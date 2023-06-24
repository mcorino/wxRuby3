
class Wx::VListBox

  wx_each_selected = instance_method :each_selected
  define_method :each_selected do |&block|
    if block
      wx_each_selected.bind(self).call(&block)
    else
      ::Enumerator.new { |y| wx_each_selected.bind(self).call { |sel| y << sel } }
    end
  end

end
