In order to find pages and content
anyone
can search for them

Scenario: Search for a page by name
  Given I am not logged in
  When I view wiki page "MainPage"
  When I fill in "search" with "blah page"
  When I press "Search"
  Then I should be on "BlahPage"

Scenario: Search for a page by wiki name
  Given I am not logged in
  When I view wiki page "MainPage"
  When I fill in "search" with "BlahPage"
  When I press "Search"
  Then I should be on "BlahPage"

Scenario: Search for a page by wiki name case insensitive
  Given I am not logged in
  When I view wiki page "MainPage"
  When I fill in "search" with "blahpage"
  When I press "Search"
  Then I should be on "BlahPage"

Scenario: Search for a page by word in title with one match only
  Given I am not logged in
  When I view wiki page "MainPage"
  When I fill in "search" with "blah"
  When I press "Search"
  Then I should be on "BlahPage"

Scenario: Search for a page by word in title
  Given I am not logged in
  When I view wiki page "MainPage"
  When I fill in "search" with "page"
  When I press "Search"
  Then I should be on "Search Results"
  And I should see 4 items in list "search_results"

Scenario: Search for non-existent page
  Given I am not logged in
  When I view wiki page "MainPage"
  When I fill in "search" with "foobar"
  When I press "Search"
  Then I should be on "Search Results"
  And I should see 0 items in list "search_results"
  And I should see "Your search didn't return any results"
