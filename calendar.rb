module SL
  class Calendar
    class << self

      def settings
        {
          trigger: '(cal|days?)',
          searches: [
            ['cal', 'Calendar'],
            ['days', 'Days in month']
          ]
        }
      end

      def search(search_type, search_terms, link_text)
        ['embed', calendar(search_type, search_terms), link_text]
      end

      def markdownify_line(line)
        "|#{line.scan(/.{3}/).join('|')}|"
      end

      def calendar(type, string)
        if type =~ /cal/
          raw = cal(type, string)
          lines = raw.split(/\n/)[0..-2]
          output = []
          header = "[#{lines.shift.strip}]"
          output << markdownify_line(lines.shift)
          output << "|---|---|---|---|---|---|---|"
          output.concat(lines.map { |l| markdownify_line(l) })
          output << header
          output.join("\n")
        else
          cal(type, string)
        end
      end

      def cal(type, string)
        case type
        when /days?/
          case string
          when /1?[0-9] \d{4}$/
            `cal -h #{string} | awk 'NF {DAYS = $NF}; END {print DAYS}'`
          else
            `cal -h | awk 'NF {DAYS = $NF}; END {print DAYS}'`
          end
        when /cal/
          case string
          when /1?[0-9] \d{4}$/
            `cal -h #{string}`
          else
            `cal -h`
          end
        end
      end
    end

    SL::Searches.register 'calendar', :search, self
  end
end
