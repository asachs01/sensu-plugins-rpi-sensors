#! /usr/bin/env ruby
#
#   check-contact-sensor.rb
#
# DESCRIPTION:
#   Checks contact sensor status provided by sensor attached to Raspberry Pi
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
#   check-contact-sensor.rb -p 5 -b :bcm
#
# NOTES:
#
# LICENSE:
#   Aaron Sachs aaronm.sachs@gmail.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'rpi_gpio'

# Starting class for check
class CheckContactSensor < Sensu::Plugin::Check::CLI
  option  :pinnum,
          short: '-p PINNUM',
          long: '--pin-num PINNUM',
          description: 'Sets the pin number the contact sensor is attached to',
          proc: proc(&:to_i),
          required: true

  option  :boardnum,
          short: '-b BOARDNUM',
          long: '--board-num BOARDNUM',
          description: 'Sets the board numbering type to either :bcm or :board',
          default: :bcm

  def initialize
    super
    RPi::GPIO.set_numbering config[:boardnum]
    RPi::GPIO.setup config[:pinnum], as: 'input', pull: 'up'
  end

  def run
    if RPi::GPIO.high? config[:pinnum]
      puts 'Contact sensor is open!'
      exit(2)
    else
      puts 'Contact sensor is closed.'
      exit(0)
    end
  end
end
