require 'test_helper'

class WikiPagesControllerTest < GitFixturesControllerTestCase
  include AuthenticatedTestHelper

  fixtures :users
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:wiki_pages)
  end

  test "should get history" do
    get :history, :wiki_page_id => 'PageWithHistory', :method => 'GET'
    assert_response :success
    assert_not_nil assigns(:wiki_page)
    assert assigns(:wiki_page).history.size > 0
  end

  test "should get new" do
    login_as :aaron
    get :new
    assert_response :success
  end
  test "should create wiki_page" do
    login_as :aaron
    assert_difference('WikiPage.count') do
      post :create, :wiki_page => { :name => 'SomeNewPage', :content => 'This is the pages content'}
    end

    assert_redirected_to wiki_page_path(assigns(:wiki_page))
  end
  test "should show wiki_page" do
    get :show, :id => 'OtherPage'
    assert_response :success
  end

  test "should get edit" do
    login_as :aaron
    get :edit, :id => 'MainPage'
    assert_response :success
  end
  test "should update wiki_page" do
    login_as :aaron
    put :update, :id => 'MainPage', :wiki_page => { :content => 'This is the new content' }
    assert_redirected_to wiki_page_path(assigns(:wiki_page))
  end

  test "should destroy wiki_page" do
    login_as :aaron
    assert_difference('WikiPage.count', -1) do
      delete :destroy, :id => 'BlahPage'
    end

    assert_redirected_to wiki_pages_path
  end
end
