#!/bin/bash

# AirBase controller IP address
baseip="10.0.1.30"
htemp=0
stemp=0
pow=0
mode=0

#Reading sensor info to get the current temperature (htemp)
function readSensorInfo {

  local response=$(curl -s http://$baseip/skyfi/aircon/get_sensor_info)

  if [[ $response =~ htemp=([0-9]{2}) ]];
  then
    htemp=${BASH_REMATCH[1]}
  fi
  }

#Reading control info to get current control values (pow, mode, stemp)
function readControlInfo {
  local response=$(curl -s http://$baseip/skyfi/aircon/get_control_info)

  if [[ $response =~ stemp=([0-9]{2}) ]];
  then
    stemp=${BASH_REMATCH[1]}
  fi

  if [[ $response =~ pow=([0-9]) ]];
  then
    pow=${BASH_REMATCH[1]}
  fi

  if [[ $response =~ mode=([0-9]) ]];
  then
    mode=${BASH_REMATCH[1]}
  fi
}

if [ "$1" = "Get" ]; then
  case "$3" in
    CurrentTemperature )
      readSensorInfo
      echo "$htemp"
      exit 0
      ;;
    TargetTemperature )
      readControlInfo
      echo "$stemp"
      exit 0
      ;;
    TemperatureDisplayUnits )
      # Celsius
      echo 0
      exit 0
      ;;
    CurrentHeatingCoolingState|TargetHeatingCoolingState )
      readControlInfo
      if [ "$pow" = "0" ]; then
        echo 0
        exit
      else
        case "$mode" in
          #Fan On = Cool/Heat Off
          0 )
          echo 0
          exit 0
          ;;
          #Heat On
          1 )
          echo 1
          exit 0
          ;;
          #Cool On
          2 )
          echo 2
          exit 0
        esac
      fi
      ;;
      #Fan state On/Off
    On )
      readControlInfo
      if [ "$pow" = "1" ] && [ "$mode" = "0" ]; then
        echo 1
        exit 0
      else
        echo 0
        exit 0
      fi
      ;;
  esac
fi

if [ "$1" = "Set" ]; then
  readControlInfo
  case "$3" in
    TargetHeatingCoolingState )
      case $4 in
        0 )
        pow=0
        ;;
        1 )
        pow=1
        mode=1
        ;;
        2 )
        pow=1
        mode=2
        ;;
      esac
    ;;
    TargetTemperature )
      stemp=$(echo "($4+0.5)/1" | bc)
      ;;
    #Turning Fan On/Off
    On )
      mode=0
      #Homebridge sets On/Off as True/False instead of 1/0
      if [[ "$4" = "true" ]]; then
        pow="1"
      else
        pow="0"
      fi
      ;;
  esac

  curl -s "http://$baseip/skyfi/aircon/set_control_info?pow=$pow&mode=$mode&stemp=$stemp&f_airside=0&f_rate=5&shum=0&f_dir=0"
  exit $?
fi

exit 1
