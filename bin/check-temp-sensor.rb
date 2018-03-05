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
#   Aaron Sachs aaronm.sachs@gmail.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'rpi_gpio'

# Starting check class
class CheckTempSensor < Sensu::Plugin::Check::CLI
  option  :fahrenheit,
          short: '-F',
          long: '--fahrenheit',
          description: 'Return temperature in Fahrenheit'

  option  :celsius,
          short: '-C',
          long: '--celsius',
          description: 'Return temperature in Celsius'

  option  :tcrit,
          short: '-c TEMP',
          long: '--critical',
          proc: proc(&:to_i),
          description: 'Critical if TEMP greater than set value'

  option  :twarn,
          short: '-w TEMP',
          long: '--warn',
          proc: proc(&:to_i),
          description: 'Warning if TEMP greater than set value'

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

  def temp_status
    critmsg = 'Temp is critical'
    warnmsg = 'Temp is abnormal'
    okmsg = 'Temp is OK'
    if config[:celsius] && read_temp > config[:tcrit]
      puts critmsg
      exit(2)
    elsif config[:celsius] && read_temp.between?(config[:tcrit], config[:twarn])
      puts warnmsg
      exit(1)
    elsif config[:fahrenheit] && temp_to_fahrenheit > config[:tcrit]
      puts critmsg
      exit(2)
    elsif config[:fahrenheit] && temp_to_fahrenheit.between?(config[:tcrit], config[:twarn])
      puts warnmsg
      exit(1)
    else
      puts okmsg
      exit(0)
    end
  end

  def run
    if config[:fahrenheit]
      puts 'Current Temp: ' + temp_to_fahrenheit.round(2).to_s + ' Fahrenheit'
    else
      puts 'Current Temp: ' + read_temp.round(2).to_s + ' Celsius'
    end
    temp_status
  end
end
