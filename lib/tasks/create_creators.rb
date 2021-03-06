class CreateCreatorsList

  def initialize
    read_person_authority
  end
  
  def create
    fn = File.join(Rails.application.config.cbeta_data, 'creators', 'all-creators.json')
    $stderr.puts "read #{fn}"
    s = File.read(fn)
    data = JSON.parse(s)

    result = {}
    data.each do |a|
      id = a.first
      if @person_names.key?(id)
        result[id] = @person_names[id]
      else
        $stderr.puts "#{__LINE__} Authority 裡沒有 #{id}".red
      end
    end

    folder = Rails.root.join('data')
    FileUtils.makedirs(folder)
    fn = File.join(folder, 'all-creators-with-alias.json')
    $stderr.puts "write #{fn}"
    s = JSON.pretty_generate(result)
    File.write(fn, s)
  end
  
  private

  def handle_preson(person)
    id = person['id']
    aliases_all = Set.new
    aliases_byline = Set.new
    regular = nil
    person.xpath('persName').each do |e|
      s = e.content
      if not e.key?('type')
        regular = s if e['lang'] == 'zho-Hant'
      elsif e['type'] == 'alternative'
        aliases_all << s
        works = Work.where("byline LIKE ?", "%#{s}%")
        aliases_byline << s unless works.empty?
      end
    end
    @person_names[id] = { regular_name: regular }
    unless aliases_all.empty?
      @person_names[id][:aliases_all] = aliases_all.to_a
    end
    unless aliases_byline.empty?
      @person_names[id][:aliases_byline] = aliases_byline.to_a
    end
  end
  
  def read_person_authority
    @person_names = {}
    fn = File.join(Rails.configuration.x.authority, 'authority_person', 'Buddhist_Studies_Person_Authority.xml')
    $stderr.puts "read #{fn}"
    doc = File.open(fn) { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!
    i = 0
    doc.xpath('//person').each do |person|
      handle_preson(person)
      i += 1
      print number_with_delimiter(i) + ' ' if (i % 500) == 0
    end
  end


end