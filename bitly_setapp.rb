# frozen_string_literal: true
# Setapp Bitly Plugin
# Takes an app name or Setapp URL, adds an affiliate string,
# and outputs a bit.ly url
#
# Requires config:
#
# ```yaml
# bitly_domain: bit.ly # or custom domain
# bitly_access_token: xxxxxxxxxxxx # see below
# setapp_affiliate_string: xxxxxxxxx # see below
# ```
#
# To get your access token:
#
# 1. Log in to bit.ly and go to <https://app.bitly.com/settings/api>
# 2. Enter your password and click Generate Token
# 3. Copy the token into the `bitly_access_token` config line
#
# To get your Setapp affiliate string
#
# 1. You must have a Setapp affiliate account through impact.com
# 2. Generate a campaign url for an app landing page
# 3. Follow the short link provided
# 4. The browser URL bar will now show the expanded link
# 5. Copy everything after the & symbol in the url to
#    the `setapp_affiliate_string` config line
#
# Run a search with !set. The input can either be a Setapp app
# landing page url, or an app name, e.g. `!set marked`,
# `[jump desktop](!set)`, or `!set https://setapp.com/apps/marked`
#
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

        unless SL.config.key?('setapp_affiliate_string') && !SL.config['setapp_affiliate_string'].empty?
          SL.add_error('Setapp affiliate string not configured', 'Missing affiliate string')
          return [false, title]
        end

        separator = url =~ /\?/ ? '&' : '?'
        url = "#{url}#{SL.config['setapp_affiliate_string'].sub(/^[?&]?/, separator)}"

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
