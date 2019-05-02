class ReportsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    
  end
  
  
  def get_reports
    session.delete(:report)
    session[:report] = params[:report]
 
    if params[:report]
      @type = params[:report][:type]
      @rank = params[:report][:rank]
      if params[:report][:type] == "Product"
        
        if params[:report][:rank] == 'cvolume'
          if params[:report][:region] == "provinces"
            make_product_province_report(params[:report])
          else
            make_nation_report(params[:report])
          end
        else
          if params[:report][:region] == "provinces"
            make_product_province_report_price(params[:report])
          else
            make_nation_report_price(params[:report])
          end
        end
        
      elsif  params[:report][:type] == "ATC"
      
        if params[:report][:rank] == 'cvolume'
          if params[:report][:region] == "provinces"
            make_report_category_by_province_volume(params[:report])
          else
            make_national_report_by_category_volume
          end
          
        else  
          if params[:report][:region] == "provinces"
            if params[:report][:start_date]
              make_report_category_by_province_value(params[:report])
            end
          else
            if params[:report][:start_date]
              make_national_report_by_category_value
            end
          end
        end
        
        
        
      else
        if params[:report][:rank] == 'cvolume'
          if params[:report][:region] == "provinces"
            make_privences_report_by_subcategory_volume(params[:report])
          else
            make_national_report_by_subcategory_volume
          end
          
        else
          if params[:report][:region] == "provinces"
            make_privences_report_by_subcategory_value(params[:report])
          else
            make_national_report_by_subcategory_value
          end
        end
        
      end
    end
  end
  
  
  
  private
  
  def make_product_province_report(params)
    if !params.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      all_prov =  Provience.where(id: params[:province_id])
      start_date = "1/2/2011".to_date.beginning_of_day
      enddate = "1/1/2016".to_date.beginning_of_day
      if !all_prov.blank? 
        ids = all_prov.collect(&:id)
        total_all = SupplierRecord.where("price > 0 and province_id IN (?) and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", ids, rep_start_date, rep_end_date).sum("totaltransactionprice")
        mpc_total =  SupplierRecord.where(province_id: ids, :created_at => start_date..enddate, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
        total = total_all.to_f + mpc_total.to_f
        
        total_quantity = SupplierRecord.where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
        
        @all_records =  SupplierRecord.joins(:product).where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).select(
          ["products.name AS description",
            "SUM(total_deliver_qty) AS total_deliver_qty",
            "product_id", 
            "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
            "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
            "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total})*100 AS price"
          ]).group("product_id").order("total_deliver_qty DESC")
      else
        @all_records = []
      end
      
      
    end
  end
  
  
  
  def make_nation_report(params)
    if !params.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      start_date = "1/2/2011".to_date.beginning_of_day
      enddate = "1/1/2016".to_date.beginning_of_day
      total_all = SupplierRecord.where("price > 0 and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(:created_at => start_date..enddate, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total = total_all.to_f + mpc_total.to_f
      total_quantity = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 

      @all_records =  SupplierRecord.joins(:product).where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select(
        ["products.name AS description","products.NSN AS customername",
          "SUM(total_deliver_qty) AS total_deliver_qty",
          "product_id", 
          "((SUM(total_deliver_qty)/ (#{total_quantity}))*100) AS outstandingorderqty",
          "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
          "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total})*100 AS price"
        ]).group("product_id").order("total_deliver_qty DESC")
    end
    
  end
  
  
  def make_nation_report_price(params)

    if !params.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      start_date = "1/2/2011".to_date.beginning_of_day
      enddate = "1/1/2016".to_date.beginning_of_day
      total_all = SupplierRecord.where("price > 0 and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(:created_at => start_date..enddate, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total = total_all.to_f + mpc_total.to_f
      total_quantity = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
      
      @all_records =  SupplierRecord.joins(:product).where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select( ["products.name AS description","products.NSN AS customername",
          "SUM(total_deliver_qty) AS total_deliver_qty",
          "product_id", 
          "((SUM(total_deliver_qty)/ (#{total_quantity}))*100) AS outstandingorderqty",
          "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
          "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total})*100 AS price"
        ]).group("product_id").order("totaltransactionprice DESC")
    end
  end
  
  
  def make_product_province_report_price(params)
    all_prov =  Provience.where(id: params[:province_id])
    start_date = "1/2/2011".to_date.beginning_of_day
    enddate = "1/1/2016".to_date.beginning_of_day
    if !all_prov.blank? 
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      ids = all_prov.collect(&:id)
      total_all = SupplierRecord.where("price > 0 and province_id IN (?) and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", ids, rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(province_id: ids, :created_at => start_date..enddate, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total = total_all.to_f + mpc_total.to_f
      total_quantity = SupplierRecord.where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
        
      @all_records =  SupplierRecord.joins(:product).where(province_id: ids , :supplierorderdipatchdate => rep_start_date..rep_end_date).select(
        ["products.name AS description",
          "SUM(total_deliver_qty) AS total_deliver_qty",
          "product_id", 
          "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
          "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
          "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total})*100 AS price"
        ]).group("product_id").order("totaltransactionprice DESC")
    else
      @all_records = []
    end
      
      
  end

  
  def make_national_report_by_subcategory_volume
    rep_start_date = params[:report][:start_date].to_date
    rep_end_date = params[:report][:end_date].to_date
    start_date = "1/2/2011".to_date.beginning_of_day
    enddate = "1/1/2016".to_date.beginning_of_day
    total_all = SupplierRecord.where("price > 0 and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", rep_start_date, rep_end_date).sum("totaltransactionprice")
    mpc_total =  SupplierRecord.where(:created_at => start_date..enddate, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
    total_price =  total_all.to_f + mpc_total.to_f
    total_quantity = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty")
    
    @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("sub_categories.id", "sub_categories.name AS description",
      "SUM(total_deliver_qty) AS total_deliver_qty",
      "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
      "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
      "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
    ).joins(product: :sub_category).group("sub_categories.id").order("total_deliver_qty DESC")
    
    
  end
  
  
  def make_national_report_by_subcategory_value
    rep_start_date = params[:report][:start_date].to_date
    rep_end_date = params[:report][:end_date].to_date
    start_date = "1/2/2011".to_date.beginning_of_day
    enddate = "1/1/2016".to_date.beginning_of_day
    total_all = SupplierRecord.where("price > 0 and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", rep_start_date, rep_end_date).sum("totaltransactionprice")
    mpc_total =  SupplierRecord.where(:created_at => start_date..enddate, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
    total_price =  total_all.to_f + mpc_total.to_f
    total_quantity = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty")
    
    @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("sub_categories.id", "sub_categories.name AS description",
      "SUM(total_deliver_qty) AS total_deliver_qty",
      "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
      "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
      "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
    ).joins(product: :sub_category).group("sub_categories.id").order("totaltransactionprice DESC")
    
  end
  
  
  
  def make_privences_report_by_subcategory_volume(params)
    
    all_prov =  Provience.where(id: params[:province_id])
    if !all_prov.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      start_date = "1/2/2011".to_date.beginning_of_day
      end_date = "1/1/2016".to_date.beginning_of_day
      ids = all_prov.collect(&:id)
      total_all = SupplierRecord.where("price > 0 and province_id IN (?) and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", ids, rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(province_id: ids, :created_at => start_date..end_date, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total_price = total_all.to_f + mpc_total.to_f
      total_quantity = SupplierRecord.where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
      
      @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("sub_categories.id", "sub_categories.name AS description",
        "SUM(total_deliver_qty) AS total_deliver_qty",
        "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
        "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
        "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
      ).where(province_id: ids).joins(product: :sub_category).group("sub_categories.id").order("total_deliver_qty DESC")
    else
      
      @all_records = []
    end
  end
  
  
  
  def make_privences_report_by_subcategory_value(params)
    all_prov =  Provience.where(id: params[:province_id])
    if !all_prov.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      start_date = "1/2/2011".to_date.beginning_of_day
      end_date = "1/1/2016".to_date.beginning_of_day
      ids = all_prov.collect(&:id)
      
      total_all = SupplierRecord.where("price > 0 and province_id IN (?) and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", ids, rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(province_id: ids, :created_at => start_date..end_date, price: 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total_price = total_all.to_f + mpc_total.to_f
      
      total_quantity = SupplierRecord.where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
      
      @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("sub_categories.id", "sub_categories.name AS description",
        "SUM(total_deliver_qty) AS total_deliver_qty",
        "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
        "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
        "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
      ).where(province_id: ids).joins(product: :sub_category).group("sub_categories.id").order("totaltransactionprice DESC")
      
    else
      @all_records = []
    end
  end
  
  
  # Start:  Report Category by National 
  
  def make_national_report_by_category_volume
    
    rep_start_date = params[:report][:start_date].to_date
    rep_end_date = params[:report][:end_date].to_date
    
    start_date = "1/2/2011".to_date.beginning_of_day
    enddate = "1/1/2016".to_date.beginning_of_day
    total_all = SupplierRecord.where("price > 0 and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", rep_start_date, rep_end_date).sum("totaltransactionprice")
    mpc_total =  SupplierRecord.where(:created_at => start_date..enddate, :price => 0, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
    
    total_price =  total_all.to_f + mpc_total.to_f
    total_quantity = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty")
    
    @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("categories.id", "categories.code AS description",
      "SUM(total_deliver_qty) AS total_deliver_qty",
      "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
      "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
      "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
    ).joins(product: :category).group("categories.id").order("total_deliver_qty DESC")
    
  end
  
  def make_national_report_by_category_value
    rep_start_date = params[:report][:start_date].to_date
    rep_end_date = params[:report][:end_date].to_date
    start_date = "1/2/2011".to_date.beginning_of_day
    enddate = "1/1/2016".to_date.beginning_of_day
    total_all = SupplierRecord.where("price > 0 and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", rep_start_date, rep_end_date).sum("totaltransactionprice")
    
    mpc_total = SupplierRecord.where(:created_at => start_date..enddate,
      :supplierorderdipatchdate => rep_start_date..rep_end_date,
      price: 0).sum(:mpcprice)
    
    total_price =  total_all.to_f + mpc_total.to_f
    total_quantity = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty")
    
    @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("categories.id","categories.code AS description",
      "SUM(total_deliver_qty)  AS total_deliver_qty",
      "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
      "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
      "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
    ).joins(product: :category).group("categories.id").order("totaltransactionprice DESC")
  end
  
  # End :  Report Category by National
  
  

  # Start:  Report Category by Province
  
  def make_report_category_by_province_volume(params)
    all_prov =  Provience.where(id: params[:province_id])
    if !all_prov.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      
      start_date = "1/2/2011".to_date.beginning_of_day
      end_date = "1/1/2016".to_date.beginning_of_day
      ids = all_prov.collect(&:id)
      
      total_all = SupplierRecord.where("price > 0 and province_id IN (?) and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", ids, rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(province_id: ids,
        :created_at => start_date..end_date, 
        :price => 0 , 
        :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total_price = total_all.to_f + mpc_total.to_f
      
      total_quantity = SupplierRecord.where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
      
      @all_records = SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("categories.id","categories.code AS description",
        "SUM(total_deliver_qty) AS total_deliver_qty",
        "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
        "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
        "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
      ).where(province_id: ids).joins(product: :category).group("categories.id").order("total_deliver_qty DESC")
      
    else
      @all_records = []
    end
  end
  
  def make_report_category_by_province_value(params)
    all_prov =  Provience.where(id: params[:province_id])
    if !all_prov.blank?
      rep_start_date = params[:start_date].to_date
      rep_end_date = params[:end_date].to_date
      start_date = "1/2/2011".to_date.beginning_of_day
      end_date = "1/1/2016".to_date.beginning_of_day
      ids = all_prov.collect(&:id)
      
      total_all = SupplierRecord.where("price > 0 and province_id IN (?) and (supplierorderdipatchdate > ? and supplierorderdipatchdate < ?)", ids, rep_start_date, rep_end_date).sum("totaltransactionprice")
      mpc_total =  SupplierRecord.where(province_id: ids, 
        :created_at => start_date..end_date,
        :price => 0,
        :supplierorderdipatchdate => rep_start_date..rep_end_date).sum(:mpcprice)
      total_price = total_all.to_f + mpc_total.to_f
      
      total_quantity = SupplierRecord.where(province_id: ids, :supplierorderdipatchdate => rep_start_date..rep_end_date).sum("total_deliver_qty") 
      
      @all_records =  SupplierRecord.where(:supplierorderdipatchdate => rep_start_date..rep_end_date).select("categories.id", "categories.code AS description",
        "SUM(total_deliver_qty) AS total_deliver_qty",
        "((SUM(total_deliver_qty)/#{total_quantity})*100) AS outstandingorderqty",
        "(SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END)) AS totaltransactionprice", 
        "((SUM(CASE WHEN price > 0 THEN totaltransactionprice ELSE 0 END) + SUM(CASE WHEN price = 0 THEN mpcprice ELSE 0 END))/#{total_price})*100 AS price"
      ).where(province_id: ids).joins(product: :category).group("categories.id").order("totaltransactionprice DESC")
      
    else
      @all_records = []
    end
  end
  # End :   Report Category by  Province
  
  
end
