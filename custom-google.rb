module SL
  # Custom Google Search
  # This plugin allows use of a Custom Google Search engine
  # 1. Make sure you have a google_api_key configured in ~/.searchlink
  # 2. Give the plugin a unique class name.
  # 3. Create an engine at https://programmablesearchengine.google.com/controlpanel/all
  #   and get the ID for it, and insert it into the @search_id variable at line 16
  # 4. Modify the trigger regex and search definition (lines 17-21)
  # 5. Change the plugin name on line 59
  # This example uses a Custom Search Engine that searches only BrettTerpstra.com
  class CustomGoogleSearch
    class << self
      attr_reader :api_key, :search_id

      def settings
        {
          trigger: "gbt",
          searches: [
            ["gbt", "BrettTerpstra.com search"],
          ],
        }
      end

      def test_for_key
        return false unless SL.config.key?("google_api_key") && SL.config["google_api_key"]

        key = SL.config["google_api_key"]
        return false if key =~ /^(x{4,})?$/i

        @api_key = key

        true
      end

      def search(_, search_terms, link_text)
        search_id = "84d644cd1af424b7a"

        unless test_for_key
          SL.add_error("api key", "Missing Google API Key")
          return false
        end

        url = "https://customsearch.googleapis.com/customsearch/v1?cx=#{search_id}&q=#{ERB::Util.url_encode(search_terms)}&num=1&key=#{@api_key}"
        json = Curl::Json.new(url).json

        return SL.ddg(terms, false) unless json["queries"]["request"][0]["totalResults"].to_i.positive?

        result = json["items"][0]
        return false if result.nil?

        output_url = result["link"]
        output_title = result["title"]
        output_title.remove_seo!(output_url) if SL.config["remove_seo"]
        [output_url, output_title, link_text]
      rescue StandardError
        SL.ddg(search_terms, link_text)
      end
    end

    SL::Searches.register "brettterpstra", :search, self
  end
end
