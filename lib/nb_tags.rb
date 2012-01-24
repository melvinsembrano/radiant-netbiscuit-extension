require 'hpricot'

module NbTags
  include Radiant::Taggable

  tag "nb" do |tag|
    tag.expand
  end

  tag "nb:page" do |tag|
    p = tag.globals.page.request.parameters
    tag.locals.page = Page.find_by_slug(p["slug"])
    tag.expand if tag.locals.page
  end

  tag "nb:pages" do |tag|
    s = %{
      <container class="article-navigation indent">
          <column>
              <BUTTONMENU>
                  <items>
                      <item class="article-nav-prev">
                          <link>[url='?page=#{prev_page(tag)}']&#171; previous[/url]</link>
                      </item>
                      <item class="article-nav-next">
                          <link>[url='?page=#{next_page(tag)}']next &#187;[/url]</link>
                      </item>
                  </items>
              </BUTTONMENU>
          </column>
      </container>      
    }
    s
  end

  tag "nb:if_next_page" do |tag|
    tag.expand unless next_page(tag) == false
  end

  tag "nb:unless_next_page" do |tag|
    tag.expand if next_page(tag) == false
  end

  tag "nb:if_prev_page" do |tag|
    tag.expand unless prev_page(tag) == false
  end

  tag "nb:unless_prev_page" do |tag|
    tag.expand if prev_page(tag) == false
  end

  tag "nb:current_page" do |tag|
    current_page(tag)
  end

  tag "nb:next_page" do |tag|
    next_page(tag)
  end

  tag "nb:prev_page" do |tag|
    prev_page(tag)
  end

  tag "nb:extract" do |tag|
    s = tag.expand
    # convert tags to bml
    
    tags = {
      "p" => "p",
      "i" => "i",
      "b" => "i",
      "strong" => "b",
      "br" => "br",
      "ul" => "ul",
      "ol" => "ol",
      "li" => "li",
    }

    tags.each do |k,v|
      s.gsub!(/<#{k}\b[^>]*>/, "[#{v}]")
      s.gsub!(/<\/#{k}\b[^>]*>/, "[/#{v}]")
    end

    finder = tag.attr['finder']
    doc = Hpricot(s)
    images = []
    doc.search("img").each { |img| images << img } #.attributes['src']}
    tag.locals.image_urls = images
    doc.search(finder).remove
    doc.to_s
  end

  tag "nb:image" do |tag|

  end

  tag "nb:images" do |tag|
    doc = Hpricot(tag.locals.page.part("body").content)
    images = []
    doc.search("img").each { |img| images << img.attributes['src']}
    tag.locals.image_urls = images
    tag.expand
  end

  tag "nb:images:if_image" do |tag|
    tag.expand if tag.locals.image_urls && tag.locals.image_urls.length > 0
  end

  tag "nb:images:unless_image" do |tag|
    tag.expand unless tag.locals.image_urls && tag.locals.image_urls.length > 0
  end

  tag "nb:images:first" do |tag|
    if tag.locals.image_urls && tag.locals.image_urls.length > 0
      return tag.locals.image_urls.first
    end
  end

  def page_link(page, text, attributes = {})
    %{<a href="?page=#{page}">#{text}</a>}
  end

  def current_index(tag)
    collection = tag.locals.paginated_list
    index = collection.current_page
  end


  def next_page(tag)
    collection = tag.locals.paginated_list
    num = collection.current_page < collection.total_pages && collection.current_page + 1
    num
  end

  def prev_page(tag)
    collection = tag.locals.paginated_list
    num = collection.current_page > 1 && collection.current_page - 1
    num
  end

end
