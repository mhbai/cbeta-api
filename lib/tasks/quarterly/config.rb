module Config
  def get_config(env)
    r = { v: 14 }
    r[:q1] = '2020Q4' # 製作 change log 時比對 q1, q2
    r[:q2] = '2021Q1'
    r[:quarter] = '2021.Q1'
    r[:publish] = '2021-01'
    r[:env] = env || Rails.env

    puts "mode: #{Rails.env}"
    case Rails.env
    when 'production'
      r[:git]           = '/home/ray/git-repos'
      r[:old]           = "/var/www/cbdata#{r[:v]-1}/shared"
      r[:root]          = "/var/www/cbdata#{r[:v]}/shared"
      r[:change_log]    = '/home/ray/cbeta-change-log'
      r[:ebook_convert] = '/usr/bin/ebook-convert'
    when 'development'
      r[:git]           = '/Users/ray/git-repos'
      r[:old]           = "/Users/ray/git-repos/cbdata12"
      r[:root]          = "/Users/ray/git-repos/cbdata13"
      r[:change_log]    = '/Users/ray/Documents/Projects/CBETA/ChangeLog'
      r[:ebook_convert] = '/Applications/calibre.app/Contents/MacOS/ebook-convert'
    when 'cn'
      r[:git] = '/mnt/CBETAOnline/git-repos'
      r[:root] = "/mnt/CBETAOnline/cbdata/shared"
    end

    r[:data]     = File.join(r[:root], 'data')
    r[:old_data] = File.join(r[:old],  'data')
    r[:public]   = File.join(r[:root], 'public')
    r[:juanline] = File.join(r[:data], 'juan-line')
    r[:figures]  = Rails.configuration.x.figures

    # eBook
    r[:download] = File.join(r[:public], 'download')
    r[:epub] = File.join(r[:download], 'epub')
    r[:mobi] = File.join(r[:download], 'mobi')
    r[:epub_template] = Rails.root.join('lib/tasks/quarterly/epub-template')

    # GitHub Repositories
    r[:authority]   = File.join(r[:git], 'Authority-Databases')
    #r[:cbr_figures] = File.join(r[:git], 'CBR2X-figures')
    r[:covers]      = File.join(r[:git], 'ebook-covers')
    r[:gaiji]       = File.join(r[:git], 'cbeta_gaiji')
    r[:metadata]    = File.join(r[:git], 'cbeta-metadata')
    r[:xml]         = File.join(r[:git], 'cbeta-xml-p5a')
    r
  end
end
