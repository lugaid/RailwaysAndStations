module ApplicationHelper
  def link_to_remove_row(name, f, html_options={})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_row(this)", html_options)
  end
  
  def link_to_add_row(name, f, association, table_id, html_options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{table_id}\")", html_options)
  end
end
