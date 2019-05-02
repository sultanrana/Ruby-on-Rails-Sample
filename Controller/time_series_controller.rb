# Start Comments
class TimeSeriesController < ApplicationController

  before_action :store_session ,:only => [:reports]
  # Start: Get General Page
  def index
    
  end
  
  # Start: Getting A list of Products
  def products
    if params[:ids]
      arraycheck =  JSON.parse(params[:ids])
      if arraycheck.length > 0
        @products = SupplierRecord.where(contractnumber: arraycheck).joins(:product).select(["products.id" , "products.name AS description"]).uniq
      end
    else
  
    end
  end

  
  # Start: Bench Mark Reprot for Tool 1 Version 1
  def reports
  
    @paramsforheader = params[:region_report]
    if params[:region_report][:sort] == "cvalue"
      @regional = Report.regional_report_by_value(params[:region_report])
      @bench = Report.bench_mark_report_by_value(params[:region_report])
      @report_hash = Report.calculate_merge_active_records(@regional, @bench, params[:region_report][:product])
    else
      @regional = Report.regional_report_by_volume(params[:region_report])
      @bench = Report.bench_mark_report_by_volume(params[:region_report])
      @report_hash = Report.calculate_merge_active_records(@regional, @bench, params[:region_report][:product])
    end
    
  end
  # End: Bench Mark Reprot for Tool 1 Version 1
  
  def graph_report
    @header = session[:tool1]
    @product = Product.find_by_id(params[:product_id])
    @array = []
    params[:value].each_with_index do |(key,val),index|
      if session[:tool1]['regions'] == key
        name = "#{key}(Bench Mark)"
        a = {name: name, y: val[:percentage].to_f.round(2),  drilldown: key}
        @array[0] = a
      else
        session[:tool1]['bench_region'].each_with_index do |value, index| 
          index = index + 1
          if value == key
            a = {name: key, y: val[:percentage].to_f.round(2),  drilldown: key}
            @array[index] = a
          end
        end
      end
  
    end

  end
  
  
  
  def province_list
    if current_user.provience_id.blank?
      if params[:name] == "National"
        @list = Provience.all.collect(&:name)
      else
        @list = Provience.where("name != ?", params[:name]).collect(&:name)
        @list.unshift('National')
      end
    else
      if params[:name] == "National"
        @list = Provience.where(id: current_user.provience_id).collect(&:name)
      else
        @list = Provience.where("name != ? and id = ?", params[:name], current_user.provience_id).collect(&:name)
        @list.unshift('National')
      end
    end
  end
  
  private
  
  def store_session
    session.delete(:tool1)
    session[:tool1] = params[:region_report]
  end

end
