module SL
  # Man Page Search
  class ManPageSearch
    class << self
      # Returns a hash of settings for the search
      #
      # @return     [Hash] the settings for the search
      #
      def settings
        {
          trigger: 'man',
          searches: [
            ['man', 'Man Page from manpages.org']
          ]
        }
      end

      # Searches for a man page for given command. Only the
      # first word of the search is used
      #
      # @param      _             [String] Search type,
      #                           unused
      # @param      search_terms  [String] the terms to
      #                           search for
      # @param      link_text     [String] the text to use
      #                           for the link
      # @return     [Array] the url, title, and link text for the
      #             search
      #
      def search(_, search_terms, link_text)
        url, title = find_man_page(search_terms)
        if url
          [url, title, link_text]
        else
          SL.ddg("site:ss64.com #{search_terms}", link_text)
        end
      end

      # Uses manpages.org autocomplete to validate command
      # name. Shortest match returned.
      #
      # @param      term  [String] the terms to search for
      # @return     [Array] the url and title for the search
      #
      def find_man_page(terms)
        terms.split(/ /).each do |term|
          autocomplete = "https://manpages.org/pagenames/autocomplete_page_name_name?term=#{ERB::Util.url_encode(term)}"
          data = Curl::Json.new(autocomplete).json
          next if data.count.zero?

          data.delete_if { |d| d['locale'] != 'en' }
          shortest = data.min_by { |d| d['permalink'].length }
          man = shortest['permalink']
          cat = shortest['category_id']
          url = "https://manpages.org/#{man}/#{cat}"
          return [url, get_man_title(url)]
        end
        [false, false]
      rescue StandardError
        false
      end

      def get_man_title(url)
        body = `/usr/bin/curl -sSL '#{url}'`
        body.match(%r{(?<=<title>).*?(?=</title>)})[0].sub(/^man /, '')
      end
    end

    # Registers the search with the SL::Searches module
    SL::Searches.register 'manpage', :search, self
  end
end
