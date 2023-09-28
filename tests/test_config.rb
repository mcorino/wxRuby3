# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class TestConfig < Test::Unit::TestCase

  DEMO_CONFIG = {
    'RootEntry1' => 'This is a string value',
    'RootEntry2' => true,
    'RootEntry3' => 101,
    'RootEntry4' => 3.14,
    'Group1' => {
      'Group1Entry' => 'Group1 string',
      'Group1.1' => {
        'Group1.1Integer' => 999,
        'Group1.1Bignum' => 2**999,
        'Group1.1Float' => (2**999)-0.1
      }
    },
    'Group2' => {
      'Group2.1' => {
        'Group2.1.1' => {
          'String' => 'hello'
        },
        'Group2.1.2' => {
          'String' => 'world'
        },
        'Group2.1.3' => {
          'True' => true,
          'False' => false
        }
      }
    }
  }

  def run_config_tests(cfg)
    assert_equal(DEMO_CONFIG, cfg.to_h)

    assert_equal(4, cfg.number_of_entries)
    assert_equal(2, cfg.number_of_groups)
    assert_equal(12, cfg.number_of_entries(recurse: true))
    assert_equal(7, cfg.number_of_groups(recurse: true))

    assert_true(cfg.has_entry?('/RootEntry2'))
    assert_true(cfg.has_entry?('/Group1/Group1Entry'))
    assert_true(cfg.has_entry?('/Group2/Group2.1/Group2.1.2/String'))

    assert_false(cfg.has_entry?('/Group2/Group2.2/Group2.1.2/String'))

    assert_true(cfg.has_group?('/Group2'))
    assert_true(cfg.has_group?('/Group1/Group1.1'))
    assert_true(cfg.has_group?('/Group2/Group2.1/Group2.1.2'))

    assert_false(cfg.has_group?('/Group2/Group2.1/Group2.1.2/String'))

    grp = cfg['/Group1/Group1.1']

    assert_equal(DEMO_CONFIG['Group1']['Group1.1'], grp.to_h)

    assert_equal(3, grp.number_of_entries)
    assert_equal(0, grp.number_of_groups)

    assert_true(grp.has_entry?('Group1.1Integer'))
    assert_false(grp.has_entry?('Group1Entry'))
    assert_true(grp.has_entry?('../Group1Entry'))

    assert_true(grp.has_group?('/Group2/Group2.1/Group2.1.2'))

    assert_equal('This is a string value', cfg['/RootEntry1'])
    assert_equal(true, cfg['/RootEntry2'])
    assert_equal(101, cfg['/RootEntry3'])
    assert_equal(3.14, cfg['/RootEntry4'])

    grp = cfg['/Group2/Group2.1/Group2.1.3']
    assert_true(grp.get('True'))
    assert_false(grp.get('False'))
    assert_nil(grp.get('../Group2.1.2/String'))

    assert_true(grp['True'])
    assert_false(grp['False'])
    assert_equal('world', grp['../Group2.1.2/String'])

    cfg.set('RootEntry1', 'Altered string value')
    assert_equal('Altered string value', cfg['RootEntry1'])
    assert_equal('Altered string value', cfg['/RootEntry1'])
    assert_equal('Altered string value', cfg.get('RootEntry1'))

    cfg.set('RootEntry3', cfg.get('RootEntry3')+99)
    assert_equal(200, cfg['/RootEntry3'])

    cfg.set('Group1', { 'Group1.2' => { 'Integer' => 777 }})
    assert_equal(777, cfg['/Group1/Group1.2/Integer'])

    cfg['/Group1/Group1.2/Integer'] = 666
    assert_equal(666, cfg['/Group1/Group1.2'].get('Integer'))

    cfg['/Group1/Group1.2'] = { 'Float' => 0.3330 }
    assert_equal(0.3330, cfg['/Group1/Group1.2'].get('Float'))
  end

  def test_basic
    cfg = Wx::Config.new(DEMO_CONFIG)

    run_config_tests(cfg)
  end

  def test_global
    cfg = Wx::ConfigBase.create

    cfg.replace(DEMO_CONFIG)

    assert_equal(DEMO_CONFIG, cfg.to_h)
    assert_equal(DEMO_CONFIG, Wx::ConfigBase.get(false).to_h)
    assert_equal(cfg, Wx::ConfigBase.get(false))

    run_config_tests(cfg)

    cfg_old = Wx::ConfigBase.set(nil)

    assert_equal(cfg, cfg_old)
    assert_nil(Wx::ConfigBase.get(false))
  end

  def test_html_help
    cfg = Wx::ConfigBase.create

    assert_true(cfg.to_h.empty?)

    hlp_ctrl = Wx::HTML::HtmlHelpController.new
    hlp_ctrl.display_index # forces help window creation which in turn enables config reading/writing

    hlp_cfg = Wx::Config.new({'htmlHelp' => {'hcNavigPanel' => true, 'hcSashPos' => 333, 'hcBaseFontSize' => 20}})
    hlp_ctrl.read_customization(hlp_cfg, 'htmlHelp')
    hlp_ctrl.write_customization(hlp_cfg, 'htmlHelpCopy')

    assert_true(hlp_cfg['/htmlHelp/hcNavigPanel'])
    assert_equal(333, hlp_cfg['/htmlHelp/hcSashPos'])

    assert_true(hlp_cfg['/htmlHelpCopy/hcNavigPanel'])
    assert_equal(333, hlp_cfg['/htmlHelpCopy/hcSashPos'])

    assert_true(hlp_cfg.has_entry?('/htmlHelpCopy/hcX'))
    assert_true(hlp_cfg.has_entry?('/htmlHelpCopy/hcY'))
    assert_true(hlp_cfg.has_entry?('/htmlHelpCopy/hcW'))
    assert_true(hlp_cfg.has_entry?('/htmlHelpCopy/hcH'))
  end

end
