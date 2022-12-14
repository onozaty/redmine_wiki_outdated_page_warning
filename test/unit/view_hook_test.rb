require File.expand_path('../../test_helper', __FILE__)

class ViewHookTest < ActiveSupport::TestCase
  fixtures :projects, :users, :wikis

  def setup
    @hook = RedmineWikiOutdatedPageWarning::ViewHook.instance

    @user = User.find(1)
    @wiki = Wiki.find(1)

    @controller = WikiController.new
    request = ActionDispatch::TestRequest.create
    response = ActionDispatch::TestResponse.new
    @controller.set_request!(request)
    @controller.set_response!(response)
  end

  def test_1year_ago

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user, :updated_on => Time.now.ago(365.days))
    assert page.save
    page.reload

    @controller.instance_variable_set('@content', page.content)

    @controller.stubs(:params).returns({
      :controller => 'wiki',
      :action => 'show'
    })

    Setting.plugin_redmine_wiki_outdated_page_warning['warning_message'] = 'This page has not been updated in over a year.'

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    expected = <<HTML
<script>
  $('#content').prepend('<div class="flash warning">' + "This page has not been updated in over a year." + '</div>');
</script>
HTML

    assert_equal expected, html
  end

  def test_not_1year_ago

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user, :updated_on => Time.now.ago(364.days))
    assert page.save
    page.reload

    @controller.instance_variable_set('@content', page.content)

    @controller.stubs(:params).returns({
      :controller => 'wiki',
      :action => 'show'
    })

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    expected = ''
    assert_equal expected, html
  end
 
  def test_last_updated_message

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user, :updated_on => Time.parse('2021-03-28 12:21:51'))
    assert page.save
    page.reload

    @controller.instance_variable_set('@content', page.content)

    @controller.stubs(:params).returns({
      :controller => 'wiki',
      :action => 'show'
    })

    Setting.plugin_redmine_wiki_outdated_page_warning['warning_message'] = 'Last updated: {last_updated}'

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    expected = <<HTML
<script>
  $('#content').prepend('<div class="flash warning">' + "Last updated: 03/28/2021 12:21 PM" + '</div>');
</script>
HTML

    assert_equal expected, html
  end

  def test_controller_unmatch

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user, :updated_on => Time.now.ago(555.days))
    assert page.save
    page.reload

    @controller.instance_variable_set('@content', page.content)

    @controller.stubs(:params).returns({
      :controller => 'issue',
      :action => 'show'
    })

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    assert_nil html
  end
 
  def test_action_unmatch

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user, :updated_on => Time.now.ago(555.days))
    assert page.save
    page.reload

    @controller.instance_variable_set('@content', page.content)

    @controller.stubs(:params).returns({
      :controller => 'wiki',
      :action => 'edit'
    })

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    assert_nil html
  end

  def test_nosave

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user)

    @controller.instance_variable_set('@content', page.content)

    @controller.stubs(:params).returns({
      :controller => 'wiki',
      :action => 'show'
    })

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    expected = ''
    assert_equal expected, html
  end

  def test_histroy

    # ARRANGE
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    # version: 1
    page.content = WikiContent.new(:text => "xxxxxx", :author => @user, :updated_on => Time.now.ago(400.days))
    assert page.save
    page.reload

    # version: 2
    page.content.text = "yyy"
    page.content.updated_on = Time.now.ago(399.days)
    assert page.save_with_content(page.content)

    content = page.content_for_version(1)
    assert_not content.current_version?

    @controller.instance_variable_set('@content', content)

    @controller.stubs(:params).returns({
      :controller => 'wiki',
      :action => 'show'
    })

    # ACT
    html = @hook.view_layouts_base_body_bottom({
      :controller => @controller
    })

    # ASSERT
    expected = ''
    assert_equal expected, html
  end
end
