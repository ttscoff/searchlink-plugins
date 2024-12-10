# frozen_string_literal: true
# Setapp is.gd Plugin
# Takes an app name or Setapp URL, adds an affiliate string,
# and outputs an is.gd url
#
# Requires config:
#
# ```yaml
# setapp_affiliate_string: xxxxxxxxx # see below
# ```
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
# Run a search with !seti. The input can either be a Setapp app
# landing page url, or an app name, e.g. `!seti marked`,
# `[jump desktop](!seti)`, or `!seti https://setapp.com/apps/marked`
#
module SL
  # is.gd link shortening
  class IsGdSetapp
    class << self
      def settings
        {
          trigger: 'seti',
          searches: [
            ['seti', 'is.gd Shorten Setapp Affiliate Link']
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

        isgd_shorten(link, rtitle, link_text)
      end

      def isgd_shorten(url, title = nil, link_text = nil)
        unless url =~ %r{^https://setapp.com} && SL::URL.valid_link?(url, 2)
          SL.add_error('URL is not a valid Setapp link', 'URL error')
          return [false, title]
        end

        unless SL.config.key?('setapp_affiliate_string') && !SL.config['setapp_affiliate_string'].empty?
          SL.add_error('Setapp affiliate string not configured', 'Missing affiliate string')
          return [false, title, link_text]
        end

        separator = url =~ /\?/ ? '&' : '?'
        aff_url = "#{url}#{SL.config['setapp_affiliate_string'].sub(/^[?&]?/, separator)}"

        data = Curl::Json.new("https://is.gd/create.php?format=json&url=#{CGI.escape(aff_url)}", symbolize_names: true)

        if data.json.key?('errorcode')
          SL.add_error('Error creating is.gd url', data.json[:errorcode])
          return [false, title, link_text]
        end

        link = data.json[:shorturl]
        rtitle = SL::URL.title(url)
        title = rtitle
        link_text = rtitle if link_text == '' && !SL.titleize
        [link, title, link_text]
      end
    end

    SL::Searches.register 'isgd_setapp', :search, self
  end
end
