#!/usr/bin/env ruby
#
#  metrics-temp-sensors.rb
#
# DESCRIPTION:
#   Provides temperature metrics from sensor attached to Raspberry Pi
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rpi_gpio
#
# USAGE:
#   metrics-temp-sensors.rb -F 
#
# NOTES:
#
# LICENSE:
#   Aaron Sachs aaronm.sachs@gmail.com
#   Released under the same terms as Sensu (the MIT license)
#   see LICENSE for details

require 'sensu-plugin/check/cli'
require 'rpi_gpio'

# Starting check class
class TempSensorMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option  :fahrenheit,
          short: '-F',
          long: '--fahrenheit',
          description: 'Return temperature in Fahrenheit'

  option  :celsius,
          short: '-C',
          long: '--celsius',
          description: 'Return temperature in Celsius'

  option :scheme,
          description: 'Metric naming scheme',
          short: '-s SCHEME',
          long: '--scheme SCHEME',
          default: "#{Socket.gethostname}.temp"

  # Set up variables
  def initialize
    super
    system('modprobe w1-gpio')
    system('modprobe w1-therm')
    @basedir = '/sys/bus/w1/devices/'.freeze
    @device_folder = Dir.glob(@basedir + '28*')[0]
    @device_file = @device_folder + '/w1_slave'
  end

  def read_temp
    lines = File.read(@device_file)
    while lines[0][-4..-2] != 'YES'
      sleep 0.2
      lines = File.readlines(@device_file)
    end

    equals_pos = lines[1].index('t=')
    return if equals_pos == -1

    lines[1][equals_pos + 2..-1].chomp.to_f / 1000.0
  end

  def temp_to_fahrenheit
    read_temp * 9.0 / 5.0 + 32.0
  end

  def run
    if config[:celsius]
      output
    else
      output
    end
  end
end
