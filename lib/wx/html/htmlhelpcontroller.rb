
class Wx::Html::HtmlHelpController
  def self.instance(*args)
    @instance ||= new(*args)
  end
end
