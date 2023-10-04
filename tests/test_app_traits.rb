# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class AppTraitsTests < Test::Unit::TestCase

  def test_traits
    traits = Wx.get_app.get_traits
    assert_not_nil(traits)
    assert_kind_of(Wx::AppTraits, traits)
    port_id, ver_major, ver_minor, ver_micro = traits.get_toolkit_version
    port = case port_id
           when Wx::PortId::PORT_GTK; 'WXGTK'
           when Wx::PortId::PORT_MAC; 'WXOSX'
           when Wx::PortId::PORT_MSW; 'WXMSW'
           else
             nil
           end
    assert_equal(Wx::PLATFORM, port)
    assert_true(Wx::PlatformInfo.instance.check_toolkit_version(ver_major, ver_minor, ver_micro))

    std_paths = traits.get_standard_paths
    assert_not_nil(std_paths)
    assert_kind_of(Wx::StandardPaths, std_paths)
    assert_not_empty(std_paths.config_dir)
    assert_not_empty(std_paths.data_dir)
    assert_not_empty(std_paths.documents_dir)
    assert_not_empty(std_paths.app_documents_dir)
  end

end
