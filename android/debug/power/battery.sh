#!/system/bin/sh
####################################################
#
#   1.  init for log
#       adb push battery_init.sh /sdcard/
#       adb push battery.sh /sdcard/
#       adb shell sh /sdcard/battery_init.sh
#
#   2.  get log
#       adb shell sh /sdcard/battery.sh
####################################################

#####################################
## Environment Variables
#####################################
LOGHOME="/sdcard/logs_home"
SLEEPTIME=5

#####################################
## logs home
#####################################
hide="2>&1"
DATALOGHOME=$LOGHOME/`date +%Y%m%d-%T`
OLDLOGHOME=$LOGHOME/old
if [ ! -d $LOGHOME ]; then
    mkdir -p $OLDLOGHOME
else
    mv $LOGHOME/[0-9]*  $OLDLOGHOME     #backup
fi
mkdir -p $DATALOGHOME


dmesg > $DATALOGHOME/dmesg.log &
cat /d/rpm_log > $DATALOGHOME/rpm.log &
cat /proc/sys/kernel/boot_reason > $DATALOGHOME/boot_reason.log &
cat /proc/sys/kernel/cold_boot> $DATALOGHOME/cold_boot.log &
echo "TIME(s)\t\tSOC(%)\tCURRENT_NOW(uA)\tVOLTAGE_NOW(uV)\tTEMP(Ddeg)\tSTATUS\tHEALTH\tCHARGETYPE" >$DATALOGHOME/SOCdata.txt
logcat -v time > $DATALOGHOME/logcat.log &
logcat -v time -b events > $DATALOGHOME/event.log &
logcat -v time -b radio > $DATALOGHOME/radio.log &
#tcpdump -i any -p -vv -s 0 -w $DATALOGHOME/tcpdump.log &
top -t -m 10 >> $DATALOGHOME/top.log &
service list >> $DATALOGHOME/serviceList.log &

intialHour=$(date +%h)
intialMin=$(date +%m)
intialSec=$(date +%s)
#while [ 1 ]; do
    timeHour=$(date +%h)
    timeMin=$(date +%m)
    timeSec=$(date +%s)
    hour=$(($timeHour-$intialHour))
    hour= $(($hour *3600))
    min=$(($timeMin-$intialMin))
    min= $(($min *60))
    sec=$(($timeSec-$intialSec))
    deltaTime=$(( hour + min +  sec  ))

    SOC=$(cat /sys/class/power_supply/battery/capacity)
    cnow=$(cat /sys/class/power_supply/battery/current_now)
    vnow=$(cat /sys/class/power_supply/battery/voltage_now)
    batteryTemp=$(cat /sys/class/power_supply/battery/temp)
    batteryStatus=$(cat /sys/class/power_supply/battery/status)
    batteryHealth=$(cat /sys/class/power_supply/battery/health)
    batterychrgType=$(cat /sys/class/power_supply/battery/charge_type)
    socket_pack=$(cat /proc/net/dev)
    #tcp_inode=$(cat /proc/net/tcp6)
    intterupt=$(cat /proc/interrupts)
    #all=$(cat /sys/class/power_supply/battery/uevent)
    #lbc_config=$(cat /d/qpnp_lbc/lbc_config)

    echo "$(date +%H-%M-%S)\t$SOC\t\t$cnow\t$vnow\t\t$batteryTemp\t\t$batteryStatus\t$batteryHealth\t$batterychrgType" >>$DATALOGHOME/SOCdata.txt
    echo "$(date +%H-%M-%S),$(cat /d/rpm_stats)" >> $DATALOGHOME/rpm_stats.log&
    echo "$(date +%H-%M-%S),$(cat /d/bam_dmux/stats)" >> $DATALOGHOME/bam_stats.log&
    echo "$(date +%H-%M-%S),,---,,$(cat /d/ipc_logging/bam_dmux/log)" >> $DATALOGHOME/bam_ipc.log&
    echo "$(date +%H-%M-%S),,---,,$(cat /d/ipc_logging/smd_tty/log)" >> $DATALOGHOME/smdtty_ipc.log& #不能抓
    echo "$(date +%H-%M-%S),$socket_pack" >> $DATALOGHOME/packet.log&
    echo "$(date +%H-%M-%S),$(netstat|grep ESTABLISHED)" >> $DATALOGHOME/netstat.log&
    echo "$(date +%H-%M-%S),$(cat /proc/net/tcp*)" >> $DATALOGHOME/tcp.log&
    echo "$(date +%H-%M-%S),$(cat /proc/interrupts)" >> $DATALOGHOME/intterupt.log&
    echo "$(date +%H-%M-%S),$(cat /sys/power/wake_lock)" >> $DATALOGHOME/wake_lock.log&
    echo "$(date +%H-%M-%S),$(cat /d/wakeup_sources)" >> $DATALOGHOME/wakeup_sources.log&
    echo "$(date +%H-%M-%S),$(cat /d/suspend_stats)" >> $DATALOGHOME/suspend_stats.log&
    echo "$(date +%H-%M-%S),$(cat /d/suspend_time)" >> $DATALOGHOME/suspend_time.log&
    echo "$(date +%H-%M-%S),$(ps)" >> $DATALOGHOME/ps.log&
    echo "$(date +%H-%M-%S),$(cat /d/smd/ch)" >> $DATALOGHOME/smd_ch.log&
    echo "$(date +%H-%M-%S),$(cat /d/lpm_stats/stats)" >> $DATALOGHOME/lpm.log&
    echo "$(date +%H-%M-%S),$(cat /sys/class/kgsl/kgsl-3d0/gpuclk)" >> $DATALOGHOME/gpuclk.log
    echo "$(date +%H-%M-%S),$(cat /sys/class/kgsl/kgsl-3d0/gpubusy)" >> $DATALOGHOME/gpubusy.log
    #echo "$(date +%H-%M-%S)----,$(/data/powertop -d)" >> $DATALOGHOME/powertop.log
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu0.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu1/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu1.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu2/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu2.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu3/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu3.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu4/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu4.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu5/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu5/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu5.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu6/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu6/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu6.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/devices/system/cpu/cpu7/cpufreq/scaling_cur_freq),$(cat /sys/devices/system/cpu/cpu7/cpufreq/stats/time_in_state)" >> $DATALOGHOME/cpu7.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/class/thermal/thermal_zone0/temp)" >> $DATALOGHOME/xo_therm.log&
    echo "$(date +%H-%M-%S)----,$(cat /sys/class/leds/lcd-backlight/max_brightness),,$(cat /sys/class/leds/lcd-backlight/brightness)" >> $DATALOGHOME/brightness.log&
    echo "$(date +%H-%M-%S)----,$(cat /proc/meminfo)" >> $DATALOGHOME/meminfo.log&
    echo "$(date +%H-%M-%S)----,$(cat /proc/buddyinfo)" >> $DATALOGHOME/buddyinfo.log&
    echo "$(date +%H-%M-%S)----,$(procrank)" >> $DATALOGHOME/procrank.log&
    echo "$(date +%H-%M-%S),$(dumpsys alarm)" >> $DATALOGHOME/alarm.log&
    echo "$(date +%H-%M-%S),$(dumpsys SurfaceFlinger)" >> $DATALOGHOME/Surface.log&
    echo "$(date +%H-%M-%S)----,$(dumpsys batterystats)" >> $DATALOGHOME/batteryStatus.log&
    echo "0" >/sys/kernel/debug/tracing/tracing_on && cat /sys/kernel/debug/tracing/trace > $DATALOGHOME/trace.log & #stop trace and get log
    /data/powertop -d > $DATALOGHOME/powertop.log &
    echo "----------------------$(date +%H-%M-%S)---------------\n$(/data/powertop -d)" >> $DATALOGHOME/powertop.log
    #to collect FG regs
    #	echo "\n********START**********\nTIMEDELTA=$deltaTime\n$lbc_config\n$all\n*************END************\n" >> $DATALOGHOME/lbc_config.txt
    sleep $SLEEPTIME
# done
bugreport >$DATALOGHOME/bugreport.log
# adb bugreport bugreport.zip
echo "get log end"
