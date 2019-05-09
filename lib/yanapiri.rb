require 'octokit'
require 'git'
require 'thor'
require 'yaml'
require 'ostruct'
require 'active_support/all'
require 'action_view'
require 'action_view/helpers'

require_relative './yanapiri/version'
require_relative './yanapiri/entrega'
require_relative './yanapiri/bot'
require_relative './yanapiri/transformacion_wollok'
require_relative './yanapiri/cli'

module Yanapiri
end

I18n.load_path << Dir[File.join(File.dirname(__FILE__), '/locales') + '/*.yml']
I18n.default_locale = 'es-AR'
