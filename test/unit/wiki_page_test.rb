require 'test_helper'

class WikiPageTest < GitFixturesTestCase

  test "name as title" do
    page = WikiPage.new(:name => 'ThisIsANewPage', :content => 'Some content')
    assert_equal('This Is A New Page',page.name_as_title)
  end
  test "wiki root exists" do
    assert File.exist?(APP_CONFIG[:wiki_root])
  end

  test "Name and id are the same" do
    page = WikiPage.new(:name => 'SomeNewPage', :content => 'This is some content')
    assert_equal page.id,page.name
  end

  test "update attributes" do
    page = WikiPage.new(:name => 'SomeNewPage', :content => 'This is the content')
    page.update_attributes(:content => 'This is new content')
    assert_equal('This is new content',page.content)
    assert_equal('SomeNewPage',page.name)
  end

  test "update attributes fails for name" do
    page = WikiPage.new(:name => 'SomeNewPage', :content => 'This is the content')
    assert !page.update_attributes(:name => 'NewPageName')
    assert_not_nil page.errors.on(:name)
  end

  test "find MainPage works" do
    page = WikiPage.find('MainPage')
    assert_not_nil page
    assert_equal 'MainPage',page.name
    assert_equal "This is the main page content for testing\n",page.content
    assert_equal Time.parse("Mon May 25 22:49:33 2009 -0400"),page.publish_date
  end

  test "find OtherPage works" do
    page = WikiPage.find('OtherPage')
    assert_not_nil page
    assert_equal 'OtherPage',page.name
    assert_equal "This is some\nother page\n\nThat totall rules and stuff\n" ,page.content
  end

  test "bad author setting fails" do
    assert_raises RuntimeError do
      page = WikiPage.new
      page.author = Grit::Actor.new(nil,'a@a.com')
    end
    assert_raises RuntimeError do
      page = WikiPage.new
      page.author = Grit::Actor.new('Bob',nil)
    end
  end

  test "author from user works" do
    page = WikiPage.new
    page.author = users(:aaron)
    assert_equal('aaron',page.author.name)
    assert_equal('aaron@example.com',page.author.email)
  end

  test "author from user works on init" do
    page = WikiPage.new(:author => users(:aaron))
    assert_equal('aaron',page.author.name)
    assert_equal('aaron@example.com',page.author.email)
  end

  test "author works" do
    page = WikiPage.find('BlahPage')
    assert_equal 'Zoidberg',page.author.name
    assert_equal 'zman@crabplanet.edu',page.author.email
  end

  test "can get old versions" do
    page = WikiPage.find('PageWithHistory')
    old_content = page.content_at_version('2701989a2daf37e8946f5e00059c26b506547917')
    assert_equal "h1. This is the history page\n\nHere is a line I added to make some history.\n\nHere is another line to make more history for this file.\n\nh2. A section to make history\n",old_content
  end

  test "history is accurate" do
    page = WikiPage.find('PageWithHistory')
    assert_equal 5,page.history.size
    assert_equal 'Zoidberg',page.history[0].author.name
    assert_equal 'Dave Copeland',page.history[1].author.name
    assert_equal Time.parse("Sun Jul 5 13:34:52 2009 -0400"),page.history[0].publish_date
    assert_equal Time.parse("Sun Jul 5 13:33:02 2009 -0400"),page.history[1].publish_date
    assert_equal "h1. This is the history page\n\nHere is a line I added to make some history.\n\nHere is another line to make more history for this file.\n\nh2. A section to make history\n",page.history[1].content
  end
end
