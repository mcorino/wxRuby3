class Wx::HelpController
  def self.instance(*args)
    @instance ||= new(*args)
  end
end
