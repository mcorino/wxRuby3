
YARD::Tags::Library.define_tag("Requirements", :wxrb_require)
YARD::Tags::Library.visible_tags.place(:wxrb_require).before(:author)

YARD::Templates::Engine.register_template_path File.join(__dir__, 'templates')
