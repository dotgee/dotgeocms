module CategoriesHelper

  def nested_categories(categories)
    categories.map do |message, sub_categories|
      render(message) + content_tag(:div, nested_categories(sub_categories), :class => "nested_categories")
    end.join.html_safe
  end

  def move_link(path, direction, disabled = false)
    link_to path, :class => "m-btn mini icn-only #{"disabled" if disabled}" do
      content_tag('i', :class => (direction == "up") ? "icon-arrow-up" : "icon-arrow-down"){}
    end
  end

end
