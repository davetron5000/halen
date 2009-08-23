In order to start using the app
anyone
will see the homepage

Scenario: View the homepage
  Given I am not logged in
  When I am on the homepage
  Then I should see "Main Page"
  And I should see "Login"
  And I should not see "Logout"

