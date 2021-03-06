class ExportController < ApplicationController
  def all_creators
    fn = File.join(Rails.application.config.cbeta_data, 'creators', 'all-creators.json')
    s = File.read(fn)
    data = JSON.parse(s)
    r = {}
    r[:num_found] = data.size
    r[:results] = data
    my_render(r)
  end
  
  def all_creators2
    fn = Rails.root.join('data', 'all-creators-with-alias.json')
    s = File.read(fn)
    data = JSON.parse(s)
    r = {}
    r[:num_found] = data.size
    r[:results] = data
    my_render(r)
  end

  def all_creators3
    fn = Rails.root.join('data', 'all-creators-with-alias3.json')
    s = File.read(fn)
    data = JSON.parse(s)
    r = {}
    r[:num_found] = data.size
    r[:results] = data
    my_render(r)
  end

  def all_works
    r = []
    Work.order(:sort_order).each do |w|
      h = {
        work: w.n,
        title: w.title
      }
      if w.juan_list.nil?
        if not w.juan.nil? and w.juan > 1
          h[:juans] = (1..w.juan).to_a
        end
      else
        h[:juans] = w.juan_list.split(',')
      end
      r << h
    end
    render json: r
  end
  
  def check_list
    c = params[:canon]
    works = Work.where('n like ?', "#{c}%").order(:n)
    csv_string = CSV.generate do |csv|
      csv << ["經號", "經名", "卷次"]
      works.each do |w|
        logger.fatal "Work n: #{w.n}, juan: nil" if w.juan.nil?
        (1..w.juan).each do |j|
          csv << [w.n, w.title, "卷#{j}"]
        end
      end
    end
    render plain: csv_string
  end
  
  def creator_strokes
    fn = File.join(Rails.application.config.cbeta_data, 'creators', 'creators-by-strokes.json')
    s = File.read(fn)
    render :json => s
  end
  
  def creator_strokes_works
    fn = 'creators-by-strokes-with-works.json'
    fn = File.join(Rails.application.config.cbeta_data, 'creators', fn)
    s = File.read(fn)
    render :json => s
  end
  
  def dynasty
    fn = File.join(Rails.application.config.cbeta_data, 'time', 'dynasty-all.csv')
    s = File.read(fn)
    r = {}
    r[:num_found] = s.split("\n").size - 1
    r[:results] = s
    my_render(r)
  end

  def dynasty_works
    fn = File.join(Rails.application.config.cbeta_data, 'time', 'dynasty-works.json')
    s = File.read(fn)
    render :json => s
  end
  
  def scope_selector_by_category
    children = []
    r = [
      {
        title: "選擇全部",
        key: "root",
        children: children
      }
    ]
    add_catalog_entries('CBETA', children)
    render json: r
  end
  
  def scope_selector_by_vol
    @canons = CBETA::Canon.new
    children = []
    r = [
      {
        title: "選擇全部",
        key: "root",
        children: children
      }
    ]
    CBETA::SORT_ORDER.each do |canon|
      selector_add_canon(canon, children)
    end
    render json: r
  end
  
  private
  
  def add_catalog_entries(id, dest)
    CatalogEntry.where(parent: id).order(:n).each do |ce|
      if ce.node_type == 'work'
        info = Work.get_info_by_id(ce.work)
        abort "Work 資料庫找不到：#{ce.work}, catalog_entry: #{ce.n}" if info.nil?
        title = "#{ce.work} #{info[:title]} (#{info[:juan]}卷)"
        unless info[:byline].blank?
          title += "【#{info[:byline]}】"
        end
        d = { 
          title: title,
          key: ce.work
        }
      else
        children = []
        d = { 
          title: ce.label,
          children: children
        }
        add_catalog_entries(ce.n, children)
      end
      dest << d
    end
  end
  
  def selector_add_canon(canon, dest)
    children = []
    d = { 
      title: @canons.get_canon_attr(canon, 'chinese_name'),
      children: children
    }
    id = "Vol-#{canon}"
    add_catalog_entries(id, children)
    dest << d
  end

end