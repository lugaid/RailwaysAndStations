

class RailwaysDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Railways.count,
      iTotalDisplayRecords: railways.total_entries,
      aaData: data
    }
  end

private

  def data
    railways.map do |railway|
      [
        h(railway.name),
        h(railway.abbreviation),
        h(railway.description)
      ]
    end
  end

  def products
    @railways ||= fetch_railways
  end

  def fetch_products
    railways = Railway.order("#{sort_column} #{sort_direction}")
    railways = railways.page(page).per_page(per_page)
    if params[:sSearch].present?
      railways = railways.where("name like :search or abbreviation like :search or abbreviation like :description", search: "%#{params[:sSearch]}%")
    end
    railways
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name abbreviation description]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

