require 'rubygems'
require 'redcloth'

module RedCloth::Formatters::HTML

  def gliffy(opts)
    id,align,size = opts[:text].split(/\s*\|\s*/)
    align = "left" if !align
    size = "L" if !size || size =~ /^\s*$/
    # Don't have access to the REST paths from in here it seems
    base_url = "#{APP_CONFIG['root']}/diagrams/#{id}.jpg"
    img_url = base_url + "?size=#{size}"
    link_url = base_url + '?size=T'
    "<a href=\"#{link_url}\"><img src=\"#{img_url}\" align=\"#{align}\" border=\"0\" /></a>"
  end

  def h1(opts); make_anchor('h1',opts); end
  def h2(opts); make_anchor('h2',opts); end
  def h3(opts); make_anchor('h3',opts); end
  def h4(opts); make_anchor('h4',opts); end
  def h5(opts); make_anchor('h5',opts); end

  def make_anchor(tag,opts)
    link = name_to_anchor(opts[:text])
    "<a name=\"#{link}\"></a><#{tag} onclick='location.href=\"##{link}\"'>#{opts[:text]}</#{tag}>"
  end

  def name_to_anchor(name)
    name.gsub(/[\W\s]/,'_')
  end
end

module WikiPagesHelper

  def to_html(page)
    content = page.content
    textile = page.convert_links(url_for(:controller => :wiki_pages))
    doc = RedCloth.new(textile)
    doc.to_html
  end
end
