require 'rspec'
require 'tmpdir'
require 'fileutils'

require_relative '../lib/yanapiri'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
