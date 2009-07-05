require File.dirname(__FILE__) + '/../test_helper'

class OptionsValidatorTest < ActiveSupport::TestCase

  test "tiny mce should load the valid options on init" do
    assert_not_nil TinyMCE::OptionValidator.options
  end

  test "tiny mce should allow a certain number of options" do
    assert_equal 141, TinyMCE::OptionValidator.options.size
  end

  test "the valid method accepts valid options as strings or symbols" do
    assert TinyMCE::OptionValidator.valid?('mode')
    assert TinyMCE::OptionValidator.valid?('plugins')
    assert TinyMCE::OptionValidator.valid?('theme')
    assert TinyMCE::OptionValidator.valid?(:mode)
    assert TinyMCE::OptionValidator.valid?(:plugins)
    assert TinyMCE::OptionValidator.valid?(:theme)
  end

  test "the valid method detects invalid options as strings or symbols" do
    assert !TinyMCE::OptionValidator.valid?('a_fake_option')
    assert !TinyMCE::OptionValidator.valid?(:wrong_again)
  end

  test "plugins can be set in the options validator and be valid" do
    TinyMCE::OptionValidator.plugins = Array.new
    assert !TinyMCE::OptionValidator.valid?('paste_auto_cleanup_on_paste')
    TinyMCE::OptionValidator.plugins = %w{paste}
    assert TinyMCE::OptionValidator.valid?('paste_auto_cleanup_on_paste')
  end

  test "plugins can be added at a later stage in the script" do
    TinyMCE::OptionValidator.plugins = %w{paste}
    assert TinyMCE::OptionValidator.valid?('paste_auto_cleanup_on_paste')
    TinyMCE::OptionValidator.plugins += %w{fullscreen}
    assert ['paste', 'fullscreen'], TinyMCE::OptionValidator.plugins
    assert TinyMCE::OptionValidator.valid?('fullscreen_overflow')
  end

  test "advanced theme container options get through based on regex" do
    assert TinyMCE::OptionValidator.valid?('theme_advanced_container_content1')
    assert TinyMCE::OptionValidator.valid?('theme_advanced_container_content1_align')
    assert TinyMCE::OptionValidator.valid?('theme_advanced_container_content1_class')
    assert !TinyMCE::OptionValidator.valid?('theme_advanced_container_[content]')
    assert !TinyMCE::OptionValidator.valid?('theme_advanced_container_[content]_align')
    assert !TinyMCE::OptionValidator.valid?('theme_advanced_container_[content]_class')
  end

end
