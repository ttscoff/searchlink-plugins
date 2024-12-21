# frozen_string_literal: true
# StretchLink Plugin
# Takes a shortened url and expands it
#
# Optional config:
#
# ```yaml
# stretchlink:
#   clean_url: true
#   tidy_amazon: true
# ```
# clean_url: removes tracking information from the url
# tidy_amazon: reduces amazon url to minimal information
#
module SL
  # StretchLink Plugin
  class StretchLink
    class << self
      def settings
        {
          trigger: "str(?:etch)?",
          searches: [
            ["stretch", "Expand URLs with stretchlink.cc"],
            ["str", "Expand URLs with stretchlink.cc"],
          ],
        }
      end

      def search(_, search_terms, link_text)
        return [search_terms, nil, link_text] unless SL::URL.url?(search_terms)

        settings = if SL.config.key?("stretchlink")
            SL.config["stretchlink"]
          else
            { "clean_url" => true, "tidy_amazon" => false }
          end
        query = [
          "url=#{ERB::Util.url_encode(search_terms)}",
          "clean=#{settings["clean_url"] ? "true" : "false"}",
          "tidy_amazon=false",
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

        url = if settings["tidy_amazon"] && json["expanded_url"] =~ /amazon/
            shorten_amazon(json["expanded_url"])
          else
            json["expanded_url"]
          end

        rtitle = SL::URL.title(url) || res["title"]
        if link_text.nil? || link_text.empty? || link_text == search_terms
          link_text = rtitle
        end

        [url, rtitle, link_text]
      end

      def shorten_amazon(url)
        uri = URI.parse(url)

        # Return nil if not an Amazon URL
        return url unless uri.host.include?("amazon")

        # Extract the product ID from the path
        match = uri.path.match(/\/dp\/([^\/]*)/)
        product_id = match ? match[1] : nil

        # Construct the shortened URL if the product ID is found
        clean_url = product_id ? "https://www.amazon.com/dp/#{product_id}" : nil

        clean_url + uri.query.to_s.sub(/^&?/, "?")
      end
    end

    SL::Searches.register "stretchlink", :search, self
  end
end
