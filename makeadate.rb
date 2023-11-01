# frozen_string_literal: true

require 'time'

class DateUtils
  def initialize(time_zone = 'America/Chicago')
    @time_zone = time_zone
  end

  def parsedate(date, fmt, unpad: false)
    cmd = "date_default_timezone_set('#{@time_zone}');echo strftime('%F',strtotime('#{date}'));"
    res = `php -r "#{cmd}" 2> /dev/null`
    date = Time.parse(res)
    parsed = date.strftime(fmt).gsub(/%o/, ordinal(date.strftime('%e')))
    parsed.gsub!(%r{(^|-|/|\s)0}, '\1') if unpad
    # if there's no space between time and meridiem, downcase it
    parsed.gsub!(/(\d)(AM|PM)/) do
      m = Regexp.last_match
      m[1] + m[2].downcase
    end
    parsed =~ /1969/ ? false : parsed
  end

  # Returns an ordinal number. 13 -> 13th, 21 -> 21st etc.
  def ordinal(number)
    if (11..13).include?(number.to_i % 100)
      "#{number}th"
    else
      case number.to_i % 10
      when 1
        "#{number}st"
      when 2
        "#{number}nd"
      when 3
        "#{number}rd"
      else
        "#{number}th"
      end
    end
  end

  def timeize(time_string, fmt)
    frmt = fmt.dup
    # Uses standard strftime format, but %0I will pad single-digit hours
    if time_string =~ /(\d{1,2})(?::(\d\d))?(?:\s*(a|p)m?)?/i
      m = Regexp.last_match
      hour = m[1].to_i
      minute = m[2].nil? ? '00' : m[2].to_i
      meridiem = m[3]
      meridiem = hour > 12 ? 'p' : 'a' if meridiem.nil?
      frmt.gsub!(/%H/) do
        hour = hour < 12 && meridiem == 'p' ? hour + 12 : hour
        hour = 0 if hour == 12 && meridiem == 'a'
        hour < 10 ? "0#{hour}" : hour
      end
      frmt.gsub!(/%(0)?I/) do
        hour = hour > 12 ? hour - 12 : hour
        Regexp.last_match(1) == '0' && hour < 10 ? "0#{hour}" : hour
      end
      frmt.gsub!(/%M/, format('%02d', minute.to_i))
      frmt.gsub!(/%p/, "#{meridiem.downcase}m")
      frmt.gsub!(/%P/, "#{meridiem.upcase}M")
    end
    frmt
  end
end

module SL
  # make-a-date Class
  class MakeADate
    class << self
      def settings
        {
          trigger: 'd(d(ate)?|s(hort)?|l(ng|ong)?|i(so)?)',
          searches: [
            ['ddate', 'Local date'],
            ['dshort', 'Short date'],
            ['dlong', 'Long date'],
            ['diso', 'ISO date']
          ]
        }
      end

      def search(search_type, search_terms, link_text)
        ['embed', parse_date(search_type, search_terms), link_text]
      end

      def parse_date(type, string)
        original = "#{type} #{string}"

        # split input and handle thursday@3 format
        input = original.gsub(/(\S)@(\S)/, '\1 at \2').split(/ /)
        unpad = true
        du = DateUtils.new

        # %%o is replaced with ordinal day
        fmt =  case type
               when /^dd(ate)?$/
                 unpad = false
                 '%F'
               when /^ds(hort)?$/
                 '%F'
               when /^dl(o?ng)?$/
                 '%A, %B %%o, %Y'
               when /^di(so)?$/
                 unpad = false
                 '%Y-%m-%d'
               else
                 '%F'
               end

        # handle +# to advance # days
        input.map! { |part| part.gsub(/^\+(\d+)$/, '\1 days ').gsub(/^at$/, '') }
        input.map! { |part| part.gsub(/(\d+)d/, '\1 days ').gsub(/^at$/, '') }
        input.map! { |part| part.gsub(/(\d+)w/, '\1 weeks ').gsub(/^at$/, '') }
        input.map! { |part| part.gsub(/(\d+)y/, '\1 years ').gsub(/^at$/, '') }

        # time formatting
        time_format = ''
        time_string = ''
        timerx = /(?mi)((?:at|@) *(\d{1,2}(?::\d\d)?(?:am|pm)?)|(\d{1,2}(?::\d\d)?(?:am|pm))|(\d{1,2}:\d\d))/
        if string.strip =~ /^now$/
          time_string = Time.now.strftime('%H:%M')
        elsif original.gsub(/\+\d+/, '') =~ timerx
          m = Regexp.last_match
          time_string = if m[2]
                          m[2]
                        elsif m[3]
                          m[3]
                        elsif m[4]
                          m[4]
                        end

          time_format = case type
                        when /^di/
                          du.timeize(time_string, ' %H:%M')
                        when /^dl(o?ng)?/
                          du.timeize(time_string, ' at %I:%M%p')
                        else
                          du.timeize(time_string, ' %I:%M%P')
                        end
        end

        date_string = if input.length > 1
                        if original.sub(/((@|at)\s*)?#{time_string}/, '') =~ /^\s*$/m || original.strip =~ /^now$/
                          "today #{time_format}"
                        else
                          input[1..].delete_if(&:empty?).join(' ')
                        end
                      else
                        'today'
                      end

        output = du.parsedate(date_string, fmt + time_format, unpad: unpad).gsub(/ +/, ' ')

        output || original
      end
    end

    SL::Searches.register 'makeadate', :search, self
  end
end

