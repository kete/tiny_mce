require File.expand_path(File.dirname(__FILE__) + "/../../../../test/test_helper")

# Make a test class
# Use non-default action names to get around possible authentication
# filters to ensure the tests work in most cases
class TinyMCEController < ApplicationController

  uses_tiny_mce :options => { :plugins => ['spellchecker'] },
                :raw_options => '',
                :only => ['new_page', 'edit_page']

  def new_page
    render :text => 'Hello'
  end

  def edit_page
    render :text => 'Hello'
  end

  def show_page
    render :text => 'Hello'
  end

end

class TestController
  def self.helper(s) s; end
end
