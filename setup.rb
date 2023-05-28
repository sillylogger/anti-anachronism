require 'bundler'
Bundler.require(:default)

require 'byebug'
require 'json'
require 'logging'
require 'net/http'
require 'ostruct'
require 'uri'
require 'active_support'
require 'active_support/time'

require_relative 'lib/active_record'
require_relative 'lib/hash'
require_relative 'lib/logging'
require_relative 'lib/string'
require_relative 'lib/terminal_table'
require_relative 'lib/vcr'

require_relative 'data/csv_database'

$root = FileUtils.pwd

require_relative 'google_api'
require_relative 'album'
require_relative 'photo'

