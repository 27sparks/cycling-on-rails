module ApplicationHelper
  def full_title page_title = ''
    base_title = "Cycling on Rails"
    (page_title.empty? ? '' : page_title + ' | ') + base_title
  end
end
