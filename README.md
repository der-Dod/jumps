# Jumps
## Garmin Connect IQ datafiled for counting jumps during Jump Rope activities

Download at: [Garmin Connect IQ](https://apps.garmin.com/en-US/apps/539e6c9e-a735-45c6-b390-c0bc65c1d65a)

### Description
This datafield is based on the open source [PoleSteps to FIT](https://github.com/rgergely/polesteps) steps datafield with a multiplier. The multiplier can be configured through the Connect IQ phone application or the Garmin Express PC software.
The differences are:
 - jumps counted instead of steps (jumps = steps, see below)
 - Connect IQ graphs for jumps

I found out that counting steps while jumping with a rope was exactly the same as counting steps. Therefore the datafield!
If your steps do not match your jumps, you can still adjust the multiplier.


Description of the original "Steps to FIT" datafield:
This datafield shows the number of steps taken during an activity. It only records steps when the timer is running. At the end of the session the step data are written into the FIT file for the entire session (total number of steps) and also for the individual laps (number of steps per each lap) so that you can check it in the activity summary on the Garmin Connect website or in the Garmin Connect application.


PoleSteps can be downloaded here: [PoleSteps to FIT](https://apps.garmin.com/en-US/apps/fc007f07-cac0-4d5d-a411-e4a34840f57e). 
The original datafield without the multiplier can be downloaded from this location: [Steps to FIT](https://apps.garmin.com/en-US/apps/eb7018d6-3a13-4530-92ec-ed51d1f56e07)


### What’s New

 - v0.0.3 remove vertical oscillation.
 - v0.0.2 save vertical oscillation in FIT file.
 - v0.0.1 Initial release.


Icon from [icons8](https://icons8.de/icons/set/jump-rope")
