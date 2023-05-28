require 'logging'

# V1
# $log = Logger.new STDOUT
# $log.level = Logger::DEBUG # Fatal, Error, Warn, Info, Debug
# $log.datetime_format = "%H:%M:%S"

# V2
# $log = Logging.logger(STDOUT)
# $log.level = :debug
# $log.add_appenders \
#   Logging.appenders.stdout,
#   Logging.appenders.file(File.join('log', 'development.log'))

# V3++

Logging.format_as :inspect
Logging.backtrace false

Logging.color_scheme('bright',
  :levels => {
    :info  => :green,
    :warn  => :yellow,
    :error => :red,
    :fatal => [:white, :on_red]
  }
)

pattern_params = {
  :pattern      => '[%d] %-5l %c: %m\n',
  :date_pattern => '%Y-%m-%d %H:%M:%S'
}

Logging.appenders.stdout(
  :level  => :info,
  :layout => Logging.layouts.pattern(pattern_params.merge({
    :color_scheme => 'bright'
  }))
)

Logging.appenders.rolling_file(
  'log/development.log',
  :age    => 'daily',
  :layout => Logging.layouts.pattern(pattern_params)
)

$log = Logging.logger[' ']
$log.level = :debug
$log.add_appenders 'stdout', 'log/development.log'

# these log messages will be nicely colored
# the level will be colored differently for each message
#
# $log.debug "Logger"
# $log.info "Warming"
# $log.warn "Up..."
# $log.error StandardError.new("Ok..")
# $log.fatal "READY! 🤘"
