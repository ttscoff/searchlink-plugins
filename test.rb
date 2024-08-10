#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

class ::Hash
  def stringify_keys
    each_with_object({}) { |(k, v), hsh| hsh[k.to_s] = v.is_a?(Hash) ? v.stringify_keys : v }
  end
end

if ARGV.count.positive?
  res = {
    url: 'https://daringfireball.net/markdown',
    title: ARGV[1],
    link_text: ARGV[2]
  }

  $stdout.puts YAML.dump(res.stringify_keys)
end
