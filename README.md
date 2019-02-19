# cmd4-Daikin-Airbase
Shell script to integrate Daikin BRP15B61 Airbase controller with Homebridge using cmd4 plugin

1. Install Homebridge
2. Install homebridge-cmd4 plugin
3. Edit BRP15B61.sh with the IP address of your Daikin BRP15B61 Airbase controller
4. Copy BRP15B61.sh to a subdirectory of your .homebridge directory e.g. .homebridge/Cmd4Scripts/BRP15B61.sh
5. Make sure curl and bc are installed
6. Edit your config.json using the sample included
7. Restart Homebridge

This is a basic implementation that exposes Off/Heat/Cool modes and "Home temperature" reported by the controlles as a Thermostat HomeKit device. Auto mode is not mapped to anything and is ignored

Fan mode can be configured as a separate Fan HomeKit device

Turning Fan On from HomeKit will turn Off Thermostat and vice versa

You can test the script from he command line, use any accessory name, it's not used in the script:

bash BRP15B61.sh Get < Accessory Name > < Characteristic >
bash BRP15B61.sh Set < Accessory Name > < Characteristic > < Value >

E.g.
bash BRP15B61.sh Get Daikin CurrentTemperature
bash BRP15B61.sh Set Daikin TargetHeatingCoolingState 0
