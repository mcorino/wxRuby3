
class Wx::HTML::HtmlHelpController
  def self.instance(*args)
    @instance ||= new(*args)
  end
end
