class DocumentsController < ApplicationController
  
 
  before_action :check_authentication
  
  def index
    
  end
  
  def categroy_upload
    Product.import(params[:category_data])
    redirect_to documents_url
  end
  
  
  def product_price_upload
    Product.update_import_price(params[:mpc_product])
    redirect_to documents_url
  end
  
  
  def download_pdf
    type =  params[:type]
    params =  session[:report]
    @rank = params["rank"]
    if params and params["type"]
      if params["type"] == "Product"
        
        if params["rank"] == 'cvolume'
          if params["region"] == "provinces"
            @records = SupplierRecord.provinces_product_report_by_volume(params)
          else
            @records = SupplierRecord.national_product_report_by_volume(params)
          end
        else
          if params["region"] == "provinces"
            @records = SupplierRecord.provinces_product_report_by_price(params)
          else
            @records = SupplierRecord.national_product_report_by_price(params)
          end
        end
        
      elsif params["type"] == "ATC"
        
        if params["rank"] == 'cvolume'
          
          if params["region"] == "provinces"
            @records = SupplierRecord.province_report_category_by_volume(params)
          else
            @records = SupplierRecord.national_report_category_by_volume(params)
          end
          
        else  
          if params["region"] == "provinces"
            if params["start_date"]
              @records =  SupplierRecord.province_report_category_by_value(params)
            end
          else
            if params["start_date"]
              @records =  SupplierRecord.national_report_category_by_value(params)
            end
          end
        end
        
      else
        
        if params["rank"] == 'cvolume'
          if params["region"] == "provinces"
            @records =  SupplierRecord.province_report_sub_category_by_volume(params)
          else
            @records =  SupplierRecord.national_report_sub_category_by_volume(params)
          end
        else
          if params["region"] == "provinces"
            @records =  SupplierRecord.province_report_sub_category_by_value(params)
          else
            @records = SupplierRecord.national_report_sub_category_by_value(params)
          end
        end
        
      end
    end
    #    
    if type == "pdf"
      create_report_pdf(@records)
    else
      create_xlsx_report(@records)
    end
    
  end
  
  private
  
  # Start: Make file for download
  def make_files_for_download(records, type)
   
  end
  # End : Make file for download
  
  
  # Start: Create PDF
  def create_report_pdf(record)
    respond_to do |format|
      format.html
      format.pdf do
        render :pdf                     => 'AbcReporting',
          :disposition	                 => 'attachment',             
          :template                       => 'documents/download_pdf.pdf.erb',
          :show_as_html                   => false,    
          :page_size                      => 'Letter',            
          :default_header                 => false,
          :margin => {:top => 40, :bottom => 15},
          :header => {:html => { :template => 'documents/pdfheader1.pdf.erb',
            :layout   => false, 
            :locals   => {:foo => "kashif" },
            :margin => {:top => 5, :bottom => 20 }
          },
          :background => "#000",
          :no_background                  => false,
          :image => true,
        }
      end
    end
  end
  # End : Create PDF
  
  # Start:  Create XLSX Report
  def create_xlsx_report(records)
    Supplier.make_xlsx_file(records, session[:report])
    file ="#{Rails.root}/newreport.xlsx"
    File.open(file, 'r') do |f|
      send_data f.read, :filename => "ABCReporting.xlsx", :type => "application/pdf", :disposition => "attachment"
    end
  end
  # End  : Create XLSX Report
  
end
