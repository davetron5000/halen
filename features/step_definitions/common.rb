Given /^I am not logged in$/ do
end

Then /^it should require login for manipulation$/ do
  no_clue_how_better = {
    :get => ['/wiki_pages/new','/wiki_pages/1/edit'],
    :post => ['/wiki_pages'],
    :put => ['/wiki_pages/1'],
    :delete => ['/wiki_pages/1']
  }

  no_clue_how_better.each do |method, urls|
    urls.each do |url|
      self.send(method, url)
      response.should be_redirect
      response.should redirect_to(new_session_path)
    end
  end
end

Then /^it should not require login for viewing$/ do
  no_clue_how_better = {
    :get => ['/wiki_pages','/wiki_pages/MainPage'],
  }

  no_clue_how_better.each do |method, urls|
    urls.each do |url|
      self.send(method, url)
      response.should_not be_redirect
    end
  end
end

When /^I view wiki page "([^\"]*)"$/ do |page_name|
  visit wiki_page_path(page_name)
end

Then /^I should see the link "([^\"]*)"$/ do |link_name|
  response.should have_selector('a') do |links|
    found = false
    links.each do |link|
      found = true if link.text == link_name
    end
    found
  end
end

Then /^I should see 5 list items that are links$/ do
  response.should have_selector('ol#history') do |ul|
    list = ul[0]
    list.should have_selector('li') do |list_items|
      assert list_items.size == 5
      list_items.each do |list_item|
        list_item.should have_selector('a') do |links|
          assert links.size == 1
          true
        end
      end
    end
  end
end

When /^I click link (\d+)$/ do |number|
  response.should have_selector('ol#history') do |ul|
    list = ul[0]
    list.should have_selector('li') do |list_items|
      list_items[number.to_i-1].should have_selector('a') do |links|
        click_link(links[0].text)
      end
    end
  end
end

Then /^the page title should be "([^\"]*)"$/ do |expected_title|
  response.should have_selector('head title') do |title|
    assert_equal(expected_title,title.text)
    true
  end
end


Then /^the meta keywords should be "([^\"]*)"$/ do |expected_keywords|
  found_tag = false
  response.should have_selector('meta') do |metas|
    metas.each do |meta|
      if meta['name'] == 'keywords'
        found_tag = true
        expected = expected_keywords.split(/\s*,\s*/).sort
        found_keywords = meta['content'].split(/\s*,\s*/).sort
        assert_equal(expected,found_keywords)
      end
    end
    assert found_tag
    true
  end
end
Then /^the meta "([^\"]*)" should be "([^\"]*)"$/ do |meta_tag_name,expected_description|
  found_tag = false
  response.should have_selector('meta') do |metas|
    metas.each do |meta|
      if meta['name'] == meta_tag_name
        found_tag = true
        assert_equal(expected_description,meta['content'])
      end
    end
    assert found_tag
    true
  end
end

Then /^I should see (\d+) items in list "([^\"]*)"$/ do |num_results,list_id|
  response.should have_selector("ul##{list_id}") do |lists|
    list = lists[0]
    if num_results.to_i > 0
      list.should have_selector('li') do |list_items|
        assert_equal(num_results.to_i,list_items.size,list.text)
        true
      end
      true
    else
      list.should_not have_selector('li')
      true
    end
  end
end

