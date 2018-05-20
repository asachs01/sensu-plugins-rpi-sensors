#! /usr/bin/env ruby
##
##   check-contact-sensor.rb
##
## DESCRIPTION:
##   Checks contact sensor status provided by sensor attached to Raspberry Pi
##
## OUTPUT:
##   plain text
##
## PLATFORMS:
##   Linux
##
## DEPENDENCIES:
##   gem: sensu-plugin
##   gem: rubyserial
##
## USAGE:
##   check-weight-openscale.rb -p 
##
## NOTES:
##
## LICENSE:
##   Aaron Sachs aaronm.sachs@gmail.com
##   Released under the same terms as Sensu (the MIT license); see LICENSE
##   for details.

require 'rubyserial'
require 'sensu-plugin/check/cli'

# Starting class for check
class CheckWeightOpenscale < Sensu::Plugin::Check::CLI 
  option  :port,
          short: '-p PORT',
	  long: '--port PORT',
	  description: 'Sets the port for serialruby to read',
	  required: true

  option  :writechar,
	  short: '-W WRITECHAR',
	  long: '--write-char WRITECHAR',
          description: 'Sets the write character for interacting with the Openscale board',
          required: true
  
  option  :warnweight,
          short: '-w WARNWEIGHT',
	  long: '--warn-weight WARNWEIGHT',
	  description: 'Specifies the weight that triggers a warning event',
	  required: true

  option  :critweight,
          short: '-c CRITWEIGHT',
	  long: '--crit-weight CRITWEIGHT',
	  description: 'Specifies the weight that triggers a critical event',
	  required: true

  option  :readbytes,
          short: '-r READBYTES',
	  long: '--read-bytes',
	  description: 'Specifies number of bytes to read from Openscale board',
	  proc: proc(&:to_i),
          default: 128

  def initialize
    sp = Serial.new config[:port]
    sp.write("config[:writechar]")
    weight = sp.read(config[:readbytes]).split(',')
    if weight.nil?
      do weight
    else
      
    end
  end

  def run
    if weight > config[:warnweight]
      puts 'Current Weight: ' + weight 
      exit(0)
    elsif weight.between?(config[:warnweight], config[:critweight])
      puts 'Current Weight: ' + weight
      exit(1)
    elsif weight <= config[:critweight]
      puts 'Current Weight: ' + weight
      exit(2)
    end      
  end
end
