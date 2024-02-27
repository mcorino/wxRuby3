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
      'Group1_1' => {
        'Group1_1Integer' => 999,
        'Group1_1Bignum' => 2**999,
        'Group1_1Float' => (2**999)-0.1
      }
    },
    'Group2' => {
      'Group2_1' => {
        'Group2_1_1' => {
          'String' => 'hello'
        },
        'Group2_1_2' => {
          'String' => 'world'
        },
        'Group2_1_3' => {
          'True' => true,
          'False' => false
        }
      }
    }
  }

  def stringified_entry(val)
    case val
    when TrueClass,FalseClass
      val ? '1' : '0'
    when Float
      '%g' % val
    else
      val.to_s
    end
  end

  def stringified(val)
    val.is_a?(::Hash) ? val.inject({}) { |hash, pair| hash[pair.first] = stringified(pair.last); hash } : stringified_entry(val)
  end

  def assert_true_cfg(val)
    assert_block('expected "1" or true') do
      val == '1' || val == 1 || val == true
    end
  end

  def assert_false_cfg(val)
    assert_block("expected '0' or false") do
      val == '0' || val == 0 || val == false
    end
  end

  def assert_equal_cfg(expected, val)
    assert_block("expected #{expected.is_a?(::Hash) ? stringified(expected) : %Q['#{stringified(expected)}']} \nor #{expected}\nbut got #{val}") do
      expected == val || stringified(expected) == stringified(val)
    end
  end

  def run_config_tests(cfg)
    assert_equal_cfg(DEMO_CONFIG, cfg.to_h)

    assert_equal_cfg(4, cfg.number_of_entries)
    assert_equal_cfg(2, cfg.number_of_groups)
    assert_equal_cfg(12, cfg.number_of_entries(recurse: true))
    assert_equal_cfg(7, cfg.number_of_groups(recurse: true))

    assert_true(cfg.has_entry?('/RootEntry2'))
    assert_true(cfg.has_entry?('/Group1/Group1Entry'))
    assert_true(cfg.has_entry?('/Group2/Group2_1/Group2_1_2/String'))

    assert_false(cfg.has_entry?('/Group2/Group2.2/Group2_1_2/String'))

    assert_true(cfg.has_group?('/Group2'))
    assert_true(cfg.has_group?('/Group1/Group1_1'))
    assert_true(cfg.has_group?('/Group2/Group2_1/Group2_1_2'))

    assert_false(cfg.has_group?('/Group2/Group2_1/Group2_1_2/String'))

    grp = cfg['/Group1/Group1_1']

    assert_equal_cfg(DEMO_CONFIG['Group1']['Group1_1'], grp.to_h)

    assert_equal(3, grp.number_of_entries)
    assert_equal(0, grp.number_of_groups)

    assert_true(grp.has_entry?('Group1_1Integer'))
    assert_false(grp.has_entry?('Group1Entry'))
    assert_true(grp.has_entry?('../Group1Entry'))

    assert_true(grp.has_group?('/Group2/Group2_1/Group2_1_2'))

    assert_equal('This is a string value', cfg['/RootEntry1'])
    assert_equal_cfg(true, cfg['/RootEntry2'])
    assert_equal_cfg(101, cfg['/RootEntry3'])
    assert_equal_cfg(3.14, cfg['/RootEntry4'])

    grp = cfg['/Group2/Group2_1/Group2_1_3']
    assert_true_cfg(grp.get('True'))
    assert_false_cfg(grp.get('False'))
    assert_raise(ArgumentError) { grp.get('../Group2_1_2/String') }

    assert_true_cfg(grp['True'])
    assert_false_cfg(grp['False'])
    assert_equal('world', grp['../Group2_1_2/String'])

    cfg.set('RootEntry1', 'Altered string value')
    assert_equal('Altered string value', cfg['RootEntry1'])
    assert_equal('Altered string value', cfg['/RootEntry1'])
    assert_equal('Altered string value', cfg.get('RootEntry1'))

    cfg.set('RootEntry3', cfg.read('RootEntry3', ::Integer)+99)
    assert_equal_cfg(200, cfg['/RootEntry3'])

    cfg.set('Group1', { 'Group1_2' => { 'Integer' => 777 }})
    assert_equal_cfg(777, cfg['/Group1/Group1_2/Integer'])

    cfg['/Group1/Group1_2/Integer'] = 666
    assert_equal_cfg(666, cfg['/Group1/Group1_2'].get('Integer'))

    cfg['/Group1/Group1_2'] = { 'Float' => 0.3330 }
    assert_equal_cfg(0.3330, cfg['/Group1/Group1_2'].get('Float'))

    assert_equal(0.3330, cfg.read('/Group1/Group1_2/Float').to_f)
    assert_equal(0.3330, cfg.read('/Group1/Group1_2/Float', Float))
    assert_equal(0.3330, cfg.read('/Group1/Group1_2/Float', ->(v) { v.to_f }))

    cfg.replace(DEMO_CONFIG) # reset
  end

  def run_auto_accessor_tests(cfg)
    assert_not_nil(cfg.RootEntry2)
    assert_not_nil(cfg.Group1.Group1Entry)
    assert_not_nil(cfg.Group2.Group2_1.Group2_1_2.String)

    assert_nil(cfg.Group2.Group2_1.Group2_1_2.AString)

    assert_kind_of(cfg.class::Group, cfg.Group2)
    assert_kind_of(cfg.class::Group, cfg.Group1.Group1_1)
    assert_kind_of(cfg.class::Group, cfg.Group2.Group2_1.Group2_1_2)

    assert_not_kind_of(cfg.class::Group, cfg.Group2.Group2_1.Group2_1_2.String)

    grp = cfg.Group1

    assert_equal_cfg(DEMO_CONFIG['Group1'], grp.to_h)

    assert_not_nil(grp.Group1Entry)
    assert_nil(grp.Group1_1Integer)

    assert_kind_of(grp.class, grp.Group1_1)
    assert_not_nil(grp.Group1_1.Group1_1Integer)

    assert_true(grp.has_entry?('../RootEntry1'))

    assert_true(grp.has_group?('/Group2/Group2_1/Group2_1_2'))

    assert_equal_cfg('This is a string value', cfg.RootEntry1)
    assert_equal_cfg(true, cfg.RootEntry2)
    assert_equal_cfg(101, cfg.RootEntry3)
    assert_equal_cfg(3.14, cfg.RootEntry4)

    grp = cfg.Group2.Group2_1.Group2_1_3
    assert_true_cfg(grp.True)
    assert_false_cfg(grp.False)

    assert_true_cfg(grp['True'])
    assert_false_cfg(grp['False'])
    assert_equal_cfg('world', grp['../Group2_1_2/String'])

    cfg.RootEntry1 = 'Altered string value'
    assert_equal_cfg('Altered string value', cfg['RootEntry1'])
    assert_equal_cfg('Altered string value', cfg['/RootEntry1'])
    assert_equal_cfg('Altered string value', cfg.get('RootEntry1'))
    assert_equal_cfg('Altered string value', cfg.RootEntry1)

    cfg.RootEntry3 = (Kernel.Integer(cfg.RootEntry3) rescue 0)+99
    assert_equal_cfg(200, cfg.RootEntry3)

    cfg.Group1 = { 'Group1_2' => { 'Integer' => 777 }}
    assert_equal_cfg(777, cfg.Group1.Group1_2.Integer)

    cfg.Group1.Group1_2.Integer = 666
    assert_equal_cfg(666, cfg.Group1.Group1_2.get('Integer'))

    cfg.Group1.Group1_2 = { 'Float' => 0.3330 }
    assert_equal_cfg(0.3330, cfg.Group1.Group1_2.get('Float'))

    cfg.replace(DEMO_CONFIG) # reset
  end

  def run_env_var_tests(cfg)
    # by default expansion is on

    # Cirrus CI Linux builds run in privileged container without proper user env
    has_user = Wx::PLATFORM == 'WXMSW' || ENV['USER']

    # add a number of entries for env var in new group 'Environment'
    cfg['/Environment/HOME'] = '$HOME'
    cfg['Environment'].USER = Wx::PLATFORM == 'WXMSW' ? '%USERNAME%' : '${USER}' if has_user
    cfg['/Environment/PATH'] = '$(PATH)'

    assert_equal(ENV['HOME'], cfg.Environment['HOME'])
    assert_equal(ENV[Wx::PLATFORM == 'WXMSW' ?  'USERNAME' : 'USER'], cfg['/Environment/USER']) if has_user
    assert_equal(ENV['PATH'], cfg.Environment.PATH)

    # test escaping
    cfg['/Environment/Escaped_HOME'] = '\$HOME'
    cfg['/Environment/Escaped_HOME2'] = '\\$HOME'
    cfg['/Environment/Escaped_HOME3'] = '\\\$HOME'

    assert_equal('$HOME', cfg.Environment['Escaped_HOME'])
    assert_equal('$HOME', cfg.Environment['Escaped_HOME2'])
    assert_equal('\$HOME', cfg.Environment['Escaped_HOME3'])

    cfg['/Environment/NONSENSE'] = '${NonExistingLongNonsenseVariable}'

    assert_equal('${NonExistingLongNonsenseVariable}', cfg.Environment['NONSENSE'])

    cfg['/Environment/MULTIPLE'] = "$HOME / #{Wx::PLATFORM == 'WXMSW' ? '%USERNAME%' : '${USER}'}" if has_user

    assert_equal("#{ENV['HOME']} / #{Wx::PLATFORM == 'WXMSW' ? ENV['USERNAME'] : ENV['USER']}", cfg.Environment['MULTIPLE']) if has_user

    # disable env var expansion
    cfg.expand_env_vars = false
    begin
      assert_equal('$HOME', cfg.Environment['HOME'])
    ensure
      # re-enable
      cfg.set_expand_env_vars(true)
    end
  end

  def test_basic
    cfg = Wx::Config.new(DEMO_CONFIG)

    run_config_tests(cfg)
    run_auto_accessor_tests(cfg)
    run_env_var_tests(cfg)
  end

  def test_global
    cfg = Wx::ConfigBase.create(true, use_hash_config: true)

    assert_kind_of(Wx::Config, cfg)

    cfg.replace(DEMO_CONFIG)

    assert_equal(DEMO_CONFIG, cfg.to_h)
    assert_equal(DEMO_CONFIG, Wx::ConfigBase.get(false).to_h)
    assert_equal(cfg, Wx::ConfigBase.get(false))

    run_config_tests(cfg)
    run_auto_accessor_tests(cfg)
    run_env_var_tests(cfg)

    cfg_old = Wx::ConfigBase.set(nil)

    assert_equal(cfg, cfg_old)
    assert_nil(Wx::ConfigBase.get(false))
  end

  # default registry based config does not seem to do well in CI build env
  unless is_ci_build? && Wx::PLATFORM == 'WXMSW'

  def test_default_wx
    Wx::ConfigBase.set(nil) # reset global instance
    cfg = Wx::ConfigBase.get # forced auto creation of default config

    assert_kind_of(Wx::ConfigWx, cfg)

    cfg.replace(DEMO_CONFIG)

    run_config_tests(cfg)
    run_auto_accessor_tests(cfg)
    run_env_var_tests(cfg)

    assert_true(cfg.clear) # cleanup
  end

  end

  def test_html_help
    cfg = Wx::ConfigBase.create(true, use_hash_config: true)

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
