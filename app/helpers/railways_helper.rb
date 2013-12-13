module RailwaysHelper
  def link_to_edit_branch_track(name, f, association, html_options={})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.simple_fields_for(association, new_object, :child_index => "new_#{association}", :branchIdx => f.options[:child_index]) do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    
    html_options['data-editBranchTrack-association'] = association
    html_options['data-editBranchTrack-pointContent'] = fields.to_str
    
    link_to name, '#', html_options
  end
end
