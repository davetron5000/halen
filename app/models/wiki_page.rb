require 'grit'
require 'redcloth'

# Represents a wiki page
class WikiPage 

  # String representing the unique name of this page
  attr_accessor :name
  # The author, as a Grit::Actor
  attr_accessor :author
  # ActiveRecord::Errors representing errors that may have occured
  attr_reader :errors
  # The date on which this version was published
  attr_accessor :publish_date

  # The SHA-1 version number
  attr_reader :sha1

  alias :id :name

  def content
    @content
  end

  def description
    return '' if !@content
    refresh_description if !@description
    @description
  end

  def content=(content)
    @content = content
    refresh_keywords
    refresh_description
  end

  def author
    @author
  end

  def to_s
    name
  end

  def name_as_title
    if name.nil?
      nil 
    else
      name.gsub(/([A-Z])/," \\1").gsub(/^\s*/,'')
    end
  end

  def author=(new_author)
    if new_author.nil?
      @author = nil 
    else
      if (new_author.kind_of? Grit::Actor)
        raise "Author must have a name" if new_author.name.nil?
        raise "Author must have a email" if new_author.email.nil?
        @author = new_author
      else
        name = new_author.login
        name = new_author.name if new_author.name && !new_author.name.blank?
        email = new_author.email
        @author = Grit::Actor.new(name,email)
      end
    end
  end

  def initialize(options = {})
    @name = options[:name]
    @content = options[:content]
    self.author = options[:author] 
    @publish_date = options[:publish_date]
    @sha1 = options[:sha1]
    @errors = ActiveRecord::Errors.new(self)
  end

  # Updates the attributes, but doesn't actually save to the underlying store
  def update_attributes(options = {})
    if options[:name]
      @errors.clear
      @errors.add(:name,"You may not change the name")
      false
    else
      @content = options[:content] if options[:content]
      self.author = options[:author] if options[:author]
      true
    end
  end

  def save
    raise "author required" if !self.author

    File.open(actual_filename,'w') do |file|
      file.puts self.content.gsub(//,'')
    end
    git_commit
  end

  def destroy
    raise "author required" if !self.author
    File.delete(actual_filename)
    git_commit
  end

  def self.human_attribute_name(attribute)
    attribute
  end

  # Converts wiki links, rooted at +base+.
  def convert_links(base)
    first_pass = self.content.gsub(/\[w:([A-Z][a-z]+[A-Z]\w+)\(([^\)]+)\)\]/,"\"\\2\":#{base}/\\1")
    first_pass = first_pass.gsub(/\[w:([A-Z][a-z]+[A-Z]\w+)\]/,"\"\\1\":#{base}/\\1")
    first_pass
  end

  def <=>(other)
    self.name <=> other.name
  end

  def self.search(search_terms)
    return all if search_terms.nil?

    page = find(search_terms)
    page = find(wiki_name(search_terms)) if page.nil?
    if page.nil?
      results = []
      search_terms_array = search_terms.downcase.split
      all.each do |page|
        return [page] if page.name.casecmp(search_terms) == 0
        results << page if !(page.name_as_title.downcase.split & search_terms_array).empty?
      end
      results
    else
      [page]
    end
  end

  # Returns all wiki pages known to the system
  def self.all
    pages = []
    Dir.new(APP_CONFIG[:wiki_root]).entries.each do |filename|
      full_path = APP_CONFIG[:wiki_root] + '/' + filename
      if File.file? full_path
        pages << WikiPage.from_file(File.new(full_path))
      end
    end
    pages
  end

  def self.count
    self.all.size
  end
  # Finds a page by its name, which is a unique identifier.
  # Will not raise an exception if the page couldn't be found
  def self.find(name)
    begin
      file = File.open(APP_CONFIG[:wiki_root] + "/" + name) do |file|
        WikiPage.from_file(file)
      end
    rescue Exception => ex
      nil
    end
  end

  def self.history(max=30)
    history = []
    WikiPage.repo.log.each do |log|
      log.diffs.each do |diff|
        name = diff.a_path
        next if !(name =~ /^#{APP_CONFIG[:wiki_dir]}/)
        name.gsub!(/^#{APP_CONFIG[:wiki_dir]}\//,'')
        page = WikiPage.new(:name => name, :content => diff.diff, :author => log.author, :publish_date => log.date, :sha1 => log.sha)
        if history[-1] && history[-1].name == name
          history[-1] = page
        else
          history << page
        end
      end
      break if history.size >= max
    end
    history
  end

  def history
    log = WikiPage.repo.log('master',self.git_path)
    his = [self]
    log.shift
    log.each do |entry|
      his << WikiPage.new(:name => self.name, :content => content_at_version(entry.sha), :author => entry.author, :publish_date => entry.date, :sha1 => entry.sha)
    end
    his
  end

  def content_at_version(version="master")
    WikiPage.repo.git.show({},"#{version}:#{APP_CONFIG[:wiki_dir]}/#{self.name}")
  end

  # Returns the path relative to the git repo
  def git_path
    WikiPage.git_path(self.name)
  end

  def self.git_path(filename)
    APP_CONFIG[:wiki_dir] + '/' + filename
  end

  def keywords
    return [] if @content.nil?
    refresh_keywords if @keywords.nil?
    @keywords
  end

  private

  # Turns a string like "The Blah page" into "TheBlahPage"
  def self.wiki_name(non_wiki_string)
    name = ""
    non_wiki_string.downcase.split.each { |term| name << term.capitalize }
    name
  end

  def refresh_description
    @description = @content.sub(/^h1\. /,'').split(/[\.\n]/,2)[0].chomp
  end

  def refresh_keywords
    word_count = {}
    self.content.split.each do |word|
      next if is_wiki_word? word
      word.gsub!(/^\W*/,'')
      word.gsub!(/\W$/,'')
      word.downcase!
      next if is_stop_word? word
      word_count[word] ||= 0
      word_count[word] += 1
    end
    keywords = []
    word_count.sort{ |a,b|  b[1] <=> a[1] }[0..5].each do |keyval|
      keywords << keyval[0] if keyval[1] > 1
    end
    @keywords = keywords.sort
  end

  def actual_filename
    APP_CONFIG[:wiki_root] + '/' + self.name
  end

  @@repo = nil
  @@stop_words = nil

  def is_wiki_word?(word)
    word =~ /^[A-Z][a-z]+[A-Z][a-z]+/
  end

  def is_stop_word?(word)
    begin
      if @@stop_words == nil
        Rails.logger.debug("Repopulating the stop words")
        @@stop_words = {}
        File.open(APP_CONFIG[:git_root] + "/" + APP_CONFIG['stop_words']) do |file|
          file.readlines.each do |line|
            line.chomp!
            @@stop_words[line] = true if line.length >= 3
          end
        end
      end
      word.length < 3 || @@stop_words[word] || (word =~ /[^A-Za-z]/) 
    rescue Exception => ex
      Rails.logger.error(ex)
      false
    end
  end

  def self.repo
    if @@repo.nil?
      @@repo = repo = Grit::Repo.new(APP_CONFIG[:git_root])
    end
    @@repo
  end

  def self.from_file(file)
    name = file.path.split(/\//)[-1]
    log = self.repo.log('master',"#{git_path(name)}")
    WikiPage.new(:name => name,:content => file.readlines.join(""),:author => log[0].author, :publish_date => log[0].date, :sha1 => log[0].sha)
  end

  def git_commit
    wd = Dir.getwd
    results = WikiPage.repo.add(self.git_path)
    Grit.debug = true
    Grit.logger = Rails.logger
    results = WikiPage.repo.commit_index('updated',self.author)
  end

end
