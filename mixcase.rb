# Always start with module SL
module SL
  # Give it a unique class name
  class MixCaps
    class << self
      # Settings block is required with `trigger` and `searches`
      def settings
        {
          trigger: 'mix',
          searches: [
            ['mix', 'Mix Casing']
          ]
        }
      end

      def search(search_type, search_terms, link_text)
        ['embed', mix_case(search_terms), link_text]
      end

      def mix_case(string)
        string.split(//).map { |s| rand(2) == 1 ? s.upcase : s.downcase }
      end
    end


    SL::Searches.register 'mix', :search, self
  end
end
