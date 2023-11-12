# frozen_string_literal: true

def wxrb_require
  erb('wxrb_require')
end

def wxruby_requires
  object.tags(:wxrb_require).inject([]) do |list, tag|
    tag.text.split(',').each do |feature|
      list << feature.split('|').collect do |s|
        s.split('&').collect { |ss| %Q[<span class="wxrb-require">#{ss.strip}</span>] }.join('&amp;')
      end
    end
    list
  end
end
