module RailwaysHelper
  def link_to_edit_branch(name, f, association, html_options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "edit_branch(this, \"#{association}\", \"#{escape_javascript(fields)}\")", html_options)
  end
end
