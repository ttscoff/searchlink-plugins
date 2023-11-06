module SL
  # Requires google_api_key in ~/.searchlink
  class IMDBSearch
    class << self
      attr_reader :api_key

      def settings
        {
          trigger: 'imdb[ta]?',
          searches: [
            ['imdb', 'IMDB.com search'],
            ['imdba', 'IMDB.com actor search'],
            ['imdbt', 'IMDB.com title search']
          ]
        }
      end

      def test_for_key
        return false unless SL.config.key?('google_api_key') && SL.config['google_api_key']

        key = SL.config['google_api_key']
        return false if key =~ /^(x{4,})?$/i

        @api_key = key

        true
      end

      def search(search_type, search_terms, link_text)
        search_id = case search_type
                    when /a$/
                      '72c6aaca9f3144c20'
                    when /t$/
                      '97e8c7f9186d54bd1'
                    else
                      '03c787fbdb87449d1'
                    end

        unless test_for_key
          SL.add_error('api key', 'Missing Google API Key')
          return false
        end

        url = "https://customsearch.googleapis.com/customsearch/v1?cx=#{search_id}&q=#{ERB::Util.url_encode(search_terms)}&num=1&key=#{@api_key}"
        body = `curl -SsL '#{url}'`
        json = JSON.parse(body)

        return SL.ddg(terms, false) unless json['queries']['request'][0]['totalResults'].to_i.positive?

        result = json['items'][0]
        return false if result.nil?

        output_url = result['link']
        output_title = result['title']
        output_title.remove_seo!(output_url) if SL.config['remove_seo']
        [output_url, output_title, link_text]
      rescue StandardError
        SL.ddg(search_terms, link_text)
      end
    end

    SL::Searches.register 'brettterpstra', :search, self
  end
end
