# frozen_string_literal: true Shorten Amazon Plugin Takes an
# Amazon product url and shortens it to the minimal
# information needed to work
#
# Optional config:
#
# ```yaml
# stretchlink:
#  clean_url: true
# ```
#
# clean_url: removes tracking information from the url
#
module SL
  # Amazon Shorten Plugin
  class AmazonShorten
    class << self
      def settings
        {
          trigger: "sa",
          searches: [
            ["sa", "Shorten Amazon URLs"],
          ],
        }
      end

      def search(_, search_terms, link_text)
        return [search_terms, nil, link_text] unless SL::URL.url?(search_terms) && search_terms =~ /amazon\.com/

        settings = if SL.config.key?("stretchlink")
            SL.config["stretchlink"]
          else
            { "clean_url" => true, "tidy_amazon" => false }
          end
        query = [
          "url=#{ERB::Util.url_encode(search_terms)}",
          "clean=#{settings["clean_url"] ? "true" : "false"}",
          "tidy_amazon=true",
          "output=json",
        ]

        res = Curl::Json.new(%(https://stretchlink.cc/api/1?#{query.join("&")}))
        json = res.json
        if json.nil? || json.empty?
          return [search_terms, nil, link_text]
        end

        if json["error"]
          SL.error("StretchLink Error: #{json["error"]}")
          return [search_terms, nil, link_text]
        end

        rtitle = SL::URL.title(search_terms) || res["title"]
        if link_text.nil? || link_text.empty? || link_text == search_terms
          link_text = rtitle
        end

        [json["expanded_url"], rtitle, link_text]
      end
    end

    SL::Searches.register "shorten_amazon", :search, self
  end
end
