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

  tag "nb:videos" do |tag|
    tag.locals.mobile_videos = tag.locals.page.videos
    tag.expand
  end

  tag "nb:videos:first" do |tag|
    if tag.locals.mobile_videos && tag.locals.mobile_videos.count > 0
      tag.locals.mobile_video = tag.locals.mobile_videos.first
      tag.expand
    end
  end

  tag "nb:videos:if_video" do |tag|
    tag.expand  if tag.locals.mobile_videos && tag.locals.mobile_videos.count > 0
  end

  tag "nb:videos:unless_video" do |tag|
    tag.expand unless tag.locals.mobile_videos && tag.locals.mobile_videos.count > 0
  end

  tag "nb:video" do |tag|
    if tag.locals.mobile_video
      width = tag.attr["width"] || "200"
      height = tag.attr["height"] || "112"
      autoplay = tag.attr["autoplay"] || "1"
      code = tag.locals.mobile_video.embed_code
      return %{
        <preserve>
        <script src="http://player.ooyala.com/player.js?
        width=#{width}
        &height=#{height}
        &embedCode=#{code}
        &autoplay=#{autoplay}">
        </script>
        </preserve>
      }
    end
  end

  tag "nb:image" do |tag|
    tag.locals.image_url
  end

  tag "nb:images" do |tag|
    doc = Hpricot(tag.locals.page.part("body").content)
    images = []
    doc.search("img").each { |img| images << img.attributes['src']}
    tag.locals.image_urls = images
    tag.locals.image_url = images.first
    tag.expand
  end

  tag "nb:images:each" do |tag|
    result = []
    if tag.locals.image_urls
      tag.locals.image_urls.each do |u|
        tag.locals.image_url = u
        result << tag.expand
      end
    end
    result
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

end
