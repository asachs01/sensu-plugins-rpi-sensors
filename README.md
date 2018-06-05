# Sensu-plugins-rpi-sensors

## Files
bin/check-contact-sensor.rb	
bin/check-openscale-weight.rb	
bin/check-temp-sensor.rb	
bin/metrics-openscale.rb	
bin/metrics-temp-sensor.rb

## Usage
### check-contact-sensor
```json
{
  "checks":{
    "check-contact-sensor": {
      "command": "/etc/sensu/plugins/sensu-plugins-rpi-sensors/bin/check-contact-sensor.rb -p 22",
      "interval": 10
    }
  }
}
```

### check-temp-sensor
```json
{
  "checks":{
    "check-temp-sensor": {
      "command": "/etc/sensu/plugins/sensu-plugins-rpi-sensors/bin/check-temp-sensor.rb -F -w 45 -c 60",
      "interval": 15
    }
  }
}
```
### metrics-temp-sensor
```json
{
  "checks":{
    "metrics-temp-sensor": {
      "command": "/etc/sensu/plugins/sensu-plugins-rpi-sensors/bin/metrics-temp-sensor.rb -F",
      "type": "metric",
      "interval": 15
    }
  }
}
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

# License

Copyright 2018 Aaron Sachs

Released under the same terms as Sensu (the MIT license); see LICENSE
for details.
