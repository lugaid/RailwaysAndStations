module ApplicationHelper
  def link_to_add_row(name, f, association, table_id, html_options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.simple_fields_for(association, new_object, :child_index => "new_#{association}", :branchIdx => f.options[:child_index]) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    
    html_options['data-addRow-association'] = association
    html_options['data-addRow-tableid'] = table_id
    html_options['data-addRow-content'] = fields.to_str
    link_to name, '#', html_options
  end
  
  def link_to_destroy_row(name, f, html_options={})
    html_options['data-removeRow'] = true
    f.hidden_field(:_destroy) + link_to(name, "#", html_options)
  end
end
