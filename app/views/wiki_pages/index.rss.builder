xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title APP_CONFIG['wiki_name']
    xml.description APP_CONFIG['wiki_description']
    xml.link wiki_pages_url

    @wiki_pages.sort{|a,b| b.publish_date <=> a.publish_date}.each do |page|
      xml.item do
        xml.title page.name_as_title
        xml.description page.description
        xml.pubDate page.publish_date.to_s(:rfc822)
        xml.link wiki_page_url(page)
      end
    end
  end
end

