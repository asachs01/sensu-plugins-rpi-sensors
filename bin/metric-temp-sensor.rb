#!/usr/bin/env ruby
#
# check-temp-sensor.rb
#
# DESCRIPTION:
#   Checks temperature provided by sensor attached to Raspberry Pi
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rpi_gpio
#
# USAGE:
#   check-temp-sensor.rb -F -w 50 -c 70
#
# NOTES:
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license)
#   see LICENSE for details

require 'sensu-plugin/check/cli'
require 'rpi_gpio'

# Starting check class
class CheckTempSensor < Sensu::Plugin::Metric::CLI::Graphite
  option  :fahrenheit,
          short: '-F',
          long: '--fahrenheit',
          description: 'Return temperature in Fahrenheit'

  option  :celsius,
          short: '-C',
          long: '--celsius',
          description: 'Return temperature in Celsius'

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
    tempstr = 'Current Temp: '
    celstemp = tempstr + read_temp.round(2).to_s
    fahrtemp = tempstr + temp_to_fahrenheit.round(2).to_s

    if config[:celsius] && read_temp > config[:tcrit]
      critical celstemp
    elsif config[:celsius] && read_temp.between?(config[:tcrit], config[:twarn])
      warning celstemp
    elsif config[:celsius] && read_temp < config[:twarn]
      ok celstemp
    elsif config[:fahrenheit] && temp_to_fahrenheit > config[:tcrit]
      critical critmsg fahrtemp
    elsif config[:fahrenheit] && temp_to_fahrenheit.between?(config[:tcrit], config[:twarn])
      warning fahrtemp
    else
      ok fahrtemp
    end
  end
end
