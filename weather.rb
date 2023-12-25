# Always start with module SL
module SL
  # Weather and forecast plugin
  # Needs a weatherapi.com API key in config as `weather_api_key: xxxxx`
  # Provide a zip or city/region as the search term
  class WeatherSearch
    class << self
      def settings
        {
          trigger: '(fore(cast)?|cur(rent)?|wea(t(her)?)?)',
          searches: [
            ['weather', 'Embed Current Weather'],
            ['forecast', 'Embed Weather Forecast']
          ]
        }
      end

      def search(search_type, search_terms, link_text)
        api_key = SL.config['weather_api_key']
        zip = search_terms.url_encode
        url = "http://api.weatherapi.com/v1/forecast.json?key=#{api_key}&q=#{zip}&aqi=no"
        res = Curl::Json.new(url)

        raise StandardError, 'Invalid JSON response' unless res

        data = res.json

        loc = "#{data['location']['name']}, #{data['location']['region']}"
        clock = Time.parse(data['location']['localtime'])
        date = clock.strftime('%Y-%m-%d')
        time = clock.strftime('%I:%M %p')


        raise StandardError, 'Missing conditions' unless data['current']

        curr_temp = data['current']['temp_f']
        curr_condition = data['current']['condition']['text']

        raise StandardError, 'Missing forecast' unless data['forecast']

        forecast = data['forecast']['forecastday'][0]

        day = forecast['date']
        high = forecast['day']['maxtemp_f']
        low = forecast['day']['mintemp_f']
        condition = forecast['day']['condition']['text']

        output = []

        case search_type
        when /^[wc]/
          output << "Weather for #{loc} on #{date} at #{time}: #{curr_temp} and #{curr_condition}"
        else
          output << "Forecast for #{loc} on #{day}: #{condition} #{high}/#{low}"
          output << "Currently: #{curr_temp} and #{curr_condition}"
          output << ''

          output.concat(forecast_to_markdown(forecast['hour']))
        end

        output.empty? ? false : ['embed', output.join("\n"), link_text]
      end

      def forecast_to_markdown(hours)
        output = []
        temps = [
          { temp: hours[8]['temp_f'], condition: hours[8]['condition']['text'] },
          { temp: hours[10]['temp_f'], condition: hours[10]['condition']['text'] },
          { temp: hours[12]['temp_f'], condition: hours[12]['condition']['text'] },
          { temp: hours[14]['temp_f'], condition: hours[14]['condition']['text'] },
          { temp: hours[16]['temp_f'], condition: hours[16]['condition']['text'] },
          { temp: hours[18]['temp_f'], condition: hours[18]['condition']['text'] },
          { temp: hours[19]['temp_f'], condition: hours[20]['condition']['text'] }
        ]

        # Hours
        hours_text = %w[8am 10am 12pm 2pm 4pm 6pm 8pm]
        step_out = ['|']
        hours_text.each_with_index do |h, i|
          width = temps[i][:condition].length + 1
          step_out << format("%#{width}s |", h)
        end

        output << step_out.join('')

        # table separator
        step_out = ['|']
        temps.each do |temp|
          width = temp[:condition].length + 1
          step_out << "#{'-' * width}-|"
        end

        output << step_out.join('')

        # Conditions
        step_out = ['|']
        temps.each do |temp|
          step_out << format(' %s |', temp[:condition])
        end

        output << step_out.join('')

        # Temps
        step_out = ['|']
        temps.each do |temp|
          width = temp[:condition].length + 1
          step_out << format("%#{width}s |", temp[:temp])
        end

        output << step_out.join('')
      end
    end

    SL::Searches.register 'weather', :search, self
  end
end
