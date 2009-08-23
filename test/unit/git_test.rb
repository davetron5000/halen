require 'test_helper'

class GitTest < GitFixturesTestCase
  # Replace this with your real tests.
  test "git root exists" do
    assert File.exist?(APP_CONFIG[:git_root])
  end
end
