# frozen_string_literal: true

require 'shellwords'

module SL
  # Inserts a shell command result as an embed
  class ShellSnip
    class << self
      SCRIPTS_PATH = File.expand_path('~/.local/searchlink/scripts/').freeze

      def settings
        {
          trigger: 'shell',
          searches: [
            ['shell', 'Inserts Shell-Skript']
          ]
        }
      end

      def search(_, search_terms, link_text)
        result = execute_shell_script(search_terms)
        result ? ['embed', result, link_text] : false
      end

      def execute_shell_script(search_terms)
        params = Shellwords.split(search_terms)
        script_path = File.join(SCRIPTS_PATH, Shellwords.escape(params.shift))
        params.map! { |w| Shellwords.escape(w) }

        full_command = "#{Shellwords.escape(script_path)} #{params.join(' ')}"

        `#{full_command} 2>&1`
      end
    end

    SL::Searches.register 'shell', :search, self
  end
end
