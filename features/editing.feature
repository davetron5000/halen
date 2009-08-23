In order to edit pages
users must log in.

Scenario: Attempt to edit without login
    Given I am not logged in
    When I am on a wiki page
    Then it should require login for manipulation

Scenario: Attempt to view without login
    Given I am not logged in
    When I am on a wiki page
    Then it should not require login for viewing

