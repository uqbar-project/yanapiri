require 'octokit'
require 'git'
require 'thor'
require 'yaml'
require 'ostruct'
require 'active_support/all'
require 'action_view'
require 'action_view/helpers'

require_relative './yanapiri/bot'
require_relative './yanapiri/cli'
require_relative './yanapiri/entrega'
require_relative './yanapiri/multi_source_config'
require_relative './yanapiri/transformacion_wollok'
require_relative './yanapiri/version'

module Yanapiri
end

I18n.load_path << Dir[File.join(File.dirname(__FILE__), '/locales') + '/*.yml']
I18n.default_locale = 'es-AR'
