module RailwaysHelper
  def link_to_add_branch(name, f, association, table_id, html_options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.simple_fields_for(association, new_object, :child_index => "new_#{association}", :branchIdx => f.options[:child_index]) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_branch(this, \"#{association}\", \"#{escape_javascript(fields)}\", \"#{table_id}\")", html_options)
  end
  
  def link_to_edit_branch(name, f, association, html_options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.simple_fields_for(association, new_object, :child_index => "new_#{association}", :branchIdx => f.options[:child_index]) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder, :new_branch => true)
    end
    link_to_function(name, "edit_branch(this, \"#{association}\", \"#{escape_javascript(fields)}\")", html_options)
  end
  
  def link_to_destroy_branch(name, f, html_options={})
    f.hidden_field(:_destroy) + link_to_function(name, "destroy_branch(this)", html_options)
  end
end
