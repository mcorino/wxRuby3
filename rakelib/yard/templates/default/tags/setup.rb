# frozen_string_literal: true

def wxrb_require
  erb('wxrb_require')
end

def wxruby_requires
  object.tags(:wxrb_require).inject([]) do |list, tag|
    tag.text.split(',').each do |feature|
      list << feature.split('|').collect { |s| s.strip }
    end
    list
  end
end
