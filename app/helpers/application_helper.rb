# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def human_readable_date(date)
    date.strftime("%m/%d/%Y at %I:%M:%S %p")
  end

  def get_navigation_history(size=5)
    session[:history] ||= []
    return_me = session[:history][-size..-1]
    return_me || session[:history]
  end
end
