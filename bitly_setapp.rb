# frozen_string_literal: true

module SL
  # Bit.ly link shortening
  class BitlySetapp
    class << self
      def settings
        {
          trigger: 'set(?:app)?',
          searches: [
            ['set', 'bit.ly Shorten Setapp Affiliate Link'],
            ['setapp', 'bit.ly Shorten Setapp Affiliate Link'],
          ]
        }
      end

      def search(_, search_terms, link_text)
        if SL::URL.url?(search_terms)
          link = search_terms
        else
          rtitle = search_terms
          link = "https://setapp.com/apps/#{CGI.escape(search_terms.gsub(/ \d+$/, '').gsub(/ +/, "-").downcase)}"
        end

        bitly_shorten(link, rtitle, link_text)
      end

      def bitly_shorten(url, title = nil, link_text = nil)
        unless url =~ %r{^https://setapp.com} && SL::URL.valid_link?(url, 2)
          SL.add_error('URL is not a valid Setapp link', 'URL error')
          return [false, title]
        end

        unless SL.config.key?('bitly_access_token') && !SL.config['bitly_access_token'].empty?
          SL.add_error('Bit.ly not configured', 'Missing access token')
          return [false, title]
        end

        unless SL.config.key?('bitly_affiliate_string') && !SL.config['bitly_affiliate_string'].empty?
          SL.add_error('Setapp affiliate string not configured', 'Missing affiliate string')
          return [false, title]
        end

        separator = url =~ /\?/ ? '&' : '?'
        url = "#{url}#{SL.config['bitly_affiliate_string'].sub(/^[?&]?/, separator)}"

        domain = SL.config.key?('bitly_domain') ? SL.config['bitly_domain'] : 'bit.ly'
        long_url = url.dup
        curl = TTY::Which.which('curl')
        cmd = [
          %(#{curl} -SsL -H 'Authorization: Bearer #{SL.config['bitly_access_token']}'),
          %(-H 'Content-Type: application/json'),
          '-X POST', %(-d '{ "long_url": "#{url}", "domain": "#{domain}" }'), 'https://api-ssl.bitly.com/v4/shorten'
        ]
        data = JSON.parse(`#{cmd.join(' ')}`.strip)
        link = data['link']
        rtitle = SL::URL.title(long_url)
        title = rtitle
        link_text = rtitle if link_text == '' && !SL.titleize
        [link, title, link_text]
      end
    end

    SL::Searches.register 'setapp', :search, self
  end
end
