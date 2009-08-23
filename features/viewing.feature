In order to read the pages
anyone
can view them 

Scenario: View a page via direct URL
  Given I am not logged in
  When I view wiki page "MainPage"
  Then I should see "Main Page"
  And I should see "This is the main page"
  And I should see the link "History"
  And the page title should be "Test Wiki - Main Page"
  And the meta "description" should be "This is a test wiki.  This is the main page content for testing"
  And the meta "keywords" should be "test, wiki, "

Scenario: Verify the keywords
  Given I am not logged in
  When I view wiki page "PageWithHistory"
  Then the meta "description" should be "This is a test wiki.  This is the history page"
  And the meta keywords should be "test, wiki ,history,line,make"

Scenario: View a page's history and see an old version
  Given I am not logged in
  When I view wiki page "PageWithHistory"
  And I follow "History"
  Then I should see 5 list items that are links
  When I click link 4
  Then I should see "Here is a line I added to make some history"
  And I should not see "Here is another line"
  And the page title should be "Test Wiki - Page With History"

