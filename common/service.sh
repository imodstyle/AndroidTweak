#!/system/bin/sh
#===========================================================================#
# Codename: TweakMod
# Author: iModStyle @XDA
# Device: Mi5 | MSM8996 Devices
# Version : 0.2
# Last Updated: 12.JUNE.2018
#===========================================================================#
# *Credits 
# *soniCron *Alcolawl *RogerF81 *Patalao *Mostafa Wael *Senthil360 *korom42
# *and all who contributed on Nexus 5X/6P/OP3 Advanced Tweaks threads
# *Please give proper credits when using this in your work!
#===========================================================================#
# helper functions to allow Android init like script
function write() {
    echo -n $2 > $1
}
function copy() {
    cat $1 > $2
}
echo ""
echo ===================================
echo TweakMod - Begin
echo ===================================
sleep 25
busybox mount -o remount,rw -t auto /system
busybox mount -o remount,rw -t auto /data
sleep 0.1
echo "TweakMod is working !!!" > /data/TweakMod_test.log
echo "executed on $(date +"%d-%m-%Y %r")" >> /data/TweakMod_test.log
sleep 0.1
#TWEAKS_BEGIN
echo Checking Android version...
if grep -q "ro.build.version.sdk=26" /system/build.prop; then
	echo Android O 8.0.X detected!. Applying proper settings
	sleep 0.1
fi
if grep -q "ro.build.version.sdk=25" /system/build.prop; then
	echo Android N 7.1.X detected!. Applying proper settings
	sleep 0.1
fi
if grep -q "ro.build.version.sdk=24" /system/build.prop; then
	echo Android N 7.0.X detected!. Applying proper settings
	sleep 0.1
fi
if grep -q "ro.build.version.sdk=23" /system/build.prop; then
	echo Android MM 6.0.1 detected!. Applying proper settings
	sleep 0.1
fi
sleep 0.1

#Apply settings to LITTLE cluster
echo Applying settings to LITTLE Cluster...
sleep 0.1
# disable thermal hotplug to switch governor
write /sys/module/msm_thermal/core_control/enabled 0
# bring back main cores CPU 0,2
write /sys/devices/system/cpu/cpu0/online 1
write /sys/devices/system/cpu/cpu2/online 1
sleep 0.1
#Temporarily change permissions to governor files for the LITTLE cluster to enable Interactive governor
# disable thermal bcl hotplug to switch governor
    write /sys/module/msm_thermal/core_control/enabled 0
    write /sys/devices/soc/soc:qcom,bcl/mode -n disable
    bcl_hotplug_mask=`cat /sys/devices/soc/soc:qcom,bcl/hotplug_mask`
    write /sys/devices/soc/soc:qcom,bcl/hotplug_mask 0
    bcl_soc_hotplug_mask=`cat /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask`
    write /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask 0
    write /sys/devices/soc/soc:qcom,bcl/mode -n enable
    # set sync wakee policy tunable
    write /proc/sys/kernel/sched_prefer_sync_wakee_to_waker 1
    # configure governor settings for little cluster
#chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "interactive"
#chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#Grab Maximum Achievable Frequency for the LITTLE Cluster
maxfreq=$(< /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies);
if [[ $maxfreq == *"1728000"* ]]
then
    #Temporarily change permissions to governor files for the Big cluster to set the maximum frequency to 1593MHz
    echo LITTLE Cluster Overclocking detected. 
    echo Applying appropriate values.
    chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1728000
    chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
	sleep 0.1
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "75 480000:65 652800:85 729600:60 844800:85 1113600:90 1228800:70 1401600:95 1593600:70"
    chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
else
    #Temporarily change permissions to governor files for the Little cluster to set the maximum frequency to 1728MHz
    echo No LITTLE Cluster Overclocking detected. 
    echo Applying appropriate values.
    chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq 1593600   
    chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
	sleep 0.1
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "75 480000:65 652800:85 729600:60 844800:85 1113600:90 1228800:70 1401600:95 1593600:70"
    chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads
    maxfreq=$(cat "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq")
fi
chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/*
sleep 0.1

write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_slack -1
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq 307200
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load 100
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 80000
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/max_freq_hysteresis 20000
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/ignore_hispeed_on_notif 1
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu0/cpufreq/interactive/fast_ramp_down 1
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/align_windows 0
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_migration_notif 1
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/use_sched_load 0
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration 0
#write /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy 0

if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction" ]; then
    chmod 644 /sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction
    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/enable_prediction 0
fi
write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 307200
chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/interactive/*
sleep 0.1
#Apply settings to Big cluster
echo Applying settings to BIG Cluster
sleep 0.1
#Temporarily change permissions to governor files for the LITTLE cluster to enable Interactive governor
chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
write /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor interactive
chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
#Grab Maximum Achievable Frequency for the Big Cluster
maxfreq=$(< /sys/devices/system/cpu/cpu2/cpufreq/scaling_available_frequencies);
if [[ $maxfreq == *"2265600"* ]]          
then
    #Temporarily change permissions to governor files for the Big cluster to set the maximum frequency to 2150MHz
    echo BIG Cluster Overclocking detected. 
    echo Applying appropriate values.
    chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
    write /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq 2265600
    chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
    chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/interactive/target_loads
	sleep 0.1
    write /sys/devices/system/cpu/cpu2/cpufreq/interactive/target_loads "74 729600:55 806400:64 940800:76 1248000:55 1401600:69 1555200:64 1708800:74 1824000:69 1996800:75 2265600:95"
chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/interactive/target_loads
#Set overclock max frequency compatible target_loads
else
    #Temporarily change permissions to governor files for the Big cluster to set the maximum frequency to 2265MHz
    echo No BIG Cluster Overclocking detected. 
    echo Applying appropriate values.
    chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
    write /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq 2150400
    chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
    chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/interactive/target_loads
	sleep 0.1
    write /sys/devices/system/cpu/cpu2/cpufreq/interactive/target_loads "74 729600:55 806400:64 940800:76 1248000:55 1401600:69 1555200:64 1708800:74 1824000:69 1996800:75 2150400:95"
    chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/interactive/target_loads
fi

sleep 0.1
#Tweak Interactive Governor
chmod 644 /sys/devices/system/cpu/cpu2/cpufreq/interactive/*
sleep 0.1

write /sys/devices/system/cpu/cpu2/cpufreq/interactive/timer_slack -1
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/hispeed_freq 1555200
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/timer_rate 20000
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/above_hispeed_delay 0
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/go_hispeed_load 90
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/min_sample_time 60000
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/max_freq_hysteresis 20000
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/ignore_hispeed_on_notif 1
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/boost 0
write /sys/devices/system/cpu/cpu2/cpufreq/interactive/fast_ramp_down 1
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/align_windows 0
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/use_migration_notif 1
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/use_sched_load 0
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/boostpulse_duration 0
#write /sys/devices/system/cpu/cpu2/cpufreq/interactive/io_is_busy 0

write /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq 307200
chmod 444 /sys/devices/system/cpu/cpu2/cpufreq/interactive/*
sleep 0.1
# Checking ROM...
echo Checking ROM...
sleep 0.1
# Turn on core_ctl module and tune parameters if kernel has core_ctl module 
if [ -e "/sys/devices/system/cpu/cpu2/core_ctl" ]; then
write /sys/devices/system/cpu/cpu0/core_ctl/disable 0
write /sys/devices/system/cpu/cpu2/core_ctl/disable 0
write /sys/devices/system/cpu/cpu0/core_ctl/is_big_cluster 0
write /sys/devices/system/cpu/cpu0/core_ctl/min_cpus 2
write /sys/devices/system/cpu/cpu0/core_ctl/max_cpus 2
write /sys/devices/system/cpu/cpu2/core_ctl/is_big_cluster 1
write /sys/devices/system/cpu/cpu2/core_ctl/busy_down_thres 60
write /sys/devices/system/cpu/cpu2/core_ctl/busy_up_thres 85
write /sys/devices/system/cpu/cpu2/core_ctl/min_cpus 1
write /sys/devices/system/cpu/cpu2/core_ctl/max_cpus 2
fi
    # re-enable thermal and BCL hotplug
    write /sys/module/msm_thermal/core_control/enabled 1
    write /sys/devices/soc/soc:qcom,bcl/mode -n disable
    write /sys/devices/soc/soc:qcom,bcl/hotplug_mask $bcl_hotplug_mask
    write /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask $bcl_soc_hotplug_mask
    write /sys/devices/soc/soc:qcom,bcl/mode -n enable
sleep 0.1
# Input Boost
echo Disable Input Boost
if [ -e "/sys/module/cpu_boost/parameters/input_boost_freq" ]; then
chmod 644 /sys/module/cpu_boost/parameters/input_boost_freq
write /sys/module/cpu_boost/parameters/input_boost_freq "0:0 1:0 2:0 3:0"
chmod 444 /sys/module/cpu_boost/parameters/input_boost_freq
chmod 644 /sys/module/cpu_boost/parameters/input_boost_ms
write /sys/module/cpu_boost/parameters/input_boost_ms 0
chmod 444 /sys/module/cpu_boost/parameters/input_boost_ms
else
echo "*Input Boost is not avalible for your Kernel*"
fi
if [ -e "/sys/module/cpu_boost/parameters/boost_ms" ]; then
chmod 644 /sys/module/cpu_boost/parameters/boost_ms
write /sys/module/cpu_boost/parameters/boost_ms 0
chmod 444 /sys/module/cpu_boost/parameters/boost_ms
else
echo "*Cpu_Boost is not avalible for your Kernel*"
fi
sleep 0.1
#Disable TouchBoost
echo Disabling TouchBoost
    if [ -e "/sys/module/msm_performance/parameters/touchboost" ]; then
    chmod 644 /sys/module/msm_performance/parameters/touchboost
    write /sys/module/msm_performance/parameters/touchboost 0
    chmod 444 /sys/module/msm_performance/parameters/touchboost
else
    echo "*Not supported for your current Kernel*"
fi
#Tweak HMP Scheduler to feed the Big cluster more tasks
# Setting b.L scheduler parameters
write /proc/sys/kernel/sched_window_stats_policy 2
write /proc/sys/kernel/sched_upmigrate 80
write /proc/sys/kernel/sched_downmigrate 60
write /proc/sys/kernel/sched_spill_nr_run 3
#write /proc/sys/kernel/sched_spill_load 100
write /proc/sys/kernel/sched_init_task_load 2
#if [ -e "/proc/sys/kernel/sched_heavy_task" ]; then
#    write /proc/sys/kernel/sched_heavy_task 0
#fi
write /proc/sys/kernel/sched_upmigrate_min_nice 15
write /proc/sys/kernel/sched_ravg_hist_size 5
if [ -e "/proc/sys/kernel/sched_small_wakee_task_load" ]; then
write /proc/sys/kernel/sched_small_wakee_task_load 65
fi
if [ -e "/proc/sys/kernel/sched_wakeup_load_threshold" ]; then
write /proc/sys/kernel/sched_wakeup_load_threshold 110
fi
if [ -e "/proc/sys/kernel/sched_small_task" ]; then
write /proc/sys/kernel/sched_small_task 10
fi
if [ -e "/proc/sys/kernel/sched_big_waker_task_load" ]; then
write /proc/sys/kernel/sched_big_waker_task_load 80
fi
if [ -e "/proc/sys/kernel/sched_rt_runtime_us" ]; then
write /proc/sys/kernel/sched_rt_runtime_us 950000
fi
if [ -e "/proc/sys/kernel/sched_rt_period_us" ]; then
write /proc/sys/kernel/sched_rt_period_us 1000000
fi
#if [ -e "/proc/sys/kernel/sched_enable_thread_grouping" ]; then
#write /proc/sys/kernel/sched_enable_thread_grouping 0
#fi
#if [ -e "/proc/sys/kernel/sched_rr_timeslice_ms" ]; then
#write /proc/sys/kernel/sched_rr_timeslice_ms 20
#fi
if [ -e "/proc/sys/kernel/sched_migration_fixup" ]; then
write /proc/sys/kernel/sched_migration_fixup 1
fi
if [ -e "/proc/sys/kernel/sched_freq_dec_notify" ]; then
write /proc/sys/kernel/sched_freq_dec_notify 410000
fi
if [ -e "/proc/sys/kernel/sched_freq_inc_notify" ]; then
write /proc/sys/kernel/sched_freq_inc_notify 610000
fi
if [ -e "/proc/sys/kernel/sched_boost" ]; then
write /proc/sys/kernel/sched_boost 0
fi
#if [ -e "/proc/sys/kernel/sched_enable_power_aware" ]; then
#    write /proc/sys/kernel/sched_enable_power_aware 1
#fi
	if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/screen_off_maxfreq" ]; then
		write /sys/devices/system/cpu/cpu0/cpufreq/interactive/screen_off_maxfreq 307200
	fi
	if [ -e "/sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias" ]; then
		write /sys/devices/system/cpu/cpu0/cpufreq/interactive/powersave_bias 1
	fi
# if EAS is present, switch to sched governor (no effect if not EAS)
#write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor "sched"
#write /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor "sched"
#Enable Core Control and Disable MSM Thermal Throttling allowing for longer sustained performance
echo Disabling Aggressive CPU Thermal Throttling
if [ -e "/sys/module/msm_thermal/core_control/enabled" ]; then
# re-enable thermal hotplug and BCL hotplug
write /sys/module/msm_thermal/core_control/enabled 1
#	echo $bcl_hotplug_mask > /sys/devices/soc/soc:qcom,bcl/hotplug_mask
#	echo $bcl_soc_hotplug_mask > /sys/devices/soc/soc:qcom,bcl/hotplug_soc_mask
#	echo -n enable > /sys/devices/soc/soc:qcom,bcl/mode
fi
if [ -e "/sys/module/msm_thermal/parameters/enabled" ]; then
chmod 644 /sys/module/msm_thermal/parameters/enabled
write /sys/module/msm_thermal/parameters/enabled N
chmod 444 /sys/module/msm_thermal/parameters/enabled
fi

# Enable bus-dcvs
for cpubw in /sys/class/devfreq/*qcom,cpubw* ; do
    write $cpubw/governor "bw_hwmon"
    write $cpubw/polling_interval 50
    write $cpubw/min_freq 1525
    write $cpubw/bw_hwmon/mbps_zones "1525 5195 11863 13763"
    write $cpubw/bw_hwmon/sample_ms 4
    write $cpubw/bw_hwmon/io_percent 34
    write $cpubw/bw_hwmon/hist_memory 20
    write $cpubw/bw_hwmon/hyst_length 10
    write $cpubw/bw_hwmon/low_power_ceil_mbps 0
    write $cpubw/bw_hwmon/low_power_io_percent 34
    write $cpubw/bw_hwmon/low_power_delay 20
    write $cpubw/bw_hwmon/guard_band_mbps 0
    write $cpubw/bw_hwmon/up_scale 250
    write $cpubw/bw_hwmon/idle_mbps 1600
done
for memlat in /sys/class/devfreq/*qcom,memlat-cpu* ; do
    write $memlat/governor "mem_latency"
    write $memlat/polling_interval 10
done
write /sys/class/devfreq/soc:qcom,mincpubw/governor "cpufreq"

# Enable all LPMs by default
# This will enable C4, D4, D3, E4 and M3 LPMs
write /sys/module/lpm_levels/parameters/sleep_disabled N
# On debuggable builds, enable console_suspend if uart is enabled to save power
# Otherwise, disable console_suspend to get better logging for kernel crashes
if [[ $(getprop ro.debuggable) == "1" && ! -e /sys/class/tty/ttyHSL0 ]]
then
    write /sys/module/printk/parameters/console_suspend Y
fi

	soc_revision=`cat /sys/devices/soc0/revision`
	if [ "$soc_revision" == "2.0" ]; then
		#Disable suspend for v2.0
		write /sys/power/wake_lock pwr_dbg
	elif [ "$soc_revision" == "2.1" ]; then
		# Enable C4.D4.E4.M3 LPM modes
		# Disable D3 state
		write /sys/module/lpm_levels/system/pwr/pwr-l2-gdhs/idle_enabled 0
		write /sys/module/lpm_levels/system/perf/perf-l2-gdhs/idle_enabled 0
		# Disable DEF-FPC mode
		write /sys/module/lpm_levels/system/pwr/cpu0/fpc-def/idle_enabled N
		write /sys/module/lpm_levels/system/pwr/cpu1/fpc-def/idle_enabled N
		write /sys/module/lpm_levels/system/perf/cpu2/fpc-def/idle_enabled N
		write /sys/module/lpm_levels/system/perf/cpu3/fpc-def/idle_enabled N
	else
		# Enable all LPMs by default
		# This will enable C4, D4, D3, E4 and M3 LPMs
		write /sys/module/lpm_levels/parameters/sleep_disabled N
	fi
		write /sys/module/lpm_levels/parameters/sleep_disabled N

# Tweaks for other various Settings
# Tweaking GPU
sleep 0.1
echo GPU Tweaking
write /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/governor msm-adreno-tz
if grep -q "ro.build.version.sdk=23" /system/build.prop; then
chmod 644 /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/max_freq
write /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/max_freq 624000000
chmod 444 /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/max_freq
chmod 644 /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/target_freq
echo 133000000 > /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/target_freq
echo 133000000 > /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/min_freq
if [ -e "/sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/adrenoboost" ]; then
chmod 644 /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/adrenoboost
echo 0 > /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/adrenoboost
fi
fi
if [ -e "/sys/class/kgsl/kgsl-3d0/max_gpuclk" ]; then
chmod 644 /sys/class/kgsl/kgsl-3d0/max_gpuclk
write /sys/class/kgsl/kgsl-3d0/max_gpuclk 624000000
chmod 444 /sys/class/kgsl/kgsl-3d0/max_gpuclk
chmod 644 /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/target_freq
echo 133000000 > /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/target_freq
echo 133000000 > /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/min_freq
if [ -e "/sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/adrenoboost" ]; then
chmod 644 /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/adrenoboost
echo 0 > /sys/devices/soc/b00000.qcom,kgsl-3d0/devfreq/b00000.qcom,kgsl-3d0/adrenoboost
fi
fi

# disable debugging
write /sys/module/wakelock/parameters/debug_mask 0
write /sys/module/userwakelock/parameters/debug_mask 0
write /sys/module/earlysuspend/parameters/debug_mask 0
write /sys/module/alarm/parameters/debug_mask 0
write /sys/module/alarm_dev/parameters/debug_mask 0
write /sys/module/binder/parameters/debug_mask 0
write /sys/module/lowmemorykiller/parameters/debug_level 0

# Tweak memory
echo 20 > /proc/sys/vm/swappiness
echo 100 > /proc/sys/vm/vfs_cache_pressure
echo 80 > /proc/sys/vm/dirty_ratio
echo 50 > /proc/sys/vm/dirty_background_ratio
echo 4096 > /proc/sys/vm/min_free_kbytes

# Set Zram - 512 Mb
swapoff /dev/block/zram0 > /dev/null 2>&1
write /sys/block/zram0/reset "1"
write /sys/block/zram0/disksize "0"
sleep 0.1
write /sys/block/zram0/queue/add_random 0
write /sys/block/zram0/queue/iostats 0
write /sys/block/zram0/queue/nomerges 2
write /sys/block/zram0/queue/rotational 0
write /sys/block/zram0/queue/rq_affinity 1
write /sys/block/zram0/queue/nr_requests 128
write /sys/block/zram0/max_comp_streams 4
write /sys/block/zram0/disksize $((512*1024*1024))
mkswap /dev/block/zram0 > /dev/null 2>&1
swapon /dev/block/zram0 > /dev/null 2>&1

# Tweaking LMK
write /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk "0"
chmod 666 /sys/module/lowmemorykiller/parameters/minfree
chown root /sys/module/lowmemorykiller/parameters/minfree
write /sys/module/lowmemorykiller/parameters/minfree "21816,29088,36360,43632,50904,65448"

echo **[ I/O TWEAKS ]**
sleep 0.1
sch=$(cat "/sys/block/sda/queue/scheduler");

if [[ $sch == *"noop"* ]]
then
    echo Tuning "noop" ...

	for sd in /sys/block/sd* ; do
	if [ -e sys/block/sda/queue/scheduler_hard ]; then
	   write $sd/queue/scheduler_hard "noop"
    fi
   write $sd/queue/scheduler "noop"
   done
fi
if [[ $sch == *"zen"* ]]
then
    echo Tuning "zen" ...

    for sd in /sys/block/sd* ; do
    if [ -e sys/block/sda/queue/scheduler_hard ]; then
	   write $sd/queue/scheduler_hard "zen"
    fi
    write $sd/queue/scheduler "zen"
    write $sd/queue/iosched/sync_expire 300
    write $sd/queue/iosched/async_expire 3000
    write $sd/queue/iosched/fifo_batch 14
    chmod 644 $sd/queue/iosched/sync_expire
    write $sd/queue/iosched/sync_expire 300
    chmod 444 $sd/queue/iosched/sync_expire
	done
fi
if [[ $sch == *"cfq"* ]]
then
    echo Tuning "cfq" ...

	for sd in /sys/block/sd* ; do
	if [ -e sys/block/sda/queue/scheduler_hard ]; then
	   write $sd/queue/scheduler_hard "cfq"
    fi
   write $sd/queue/scheduler "cfq"
   write $sd/queue/iosched/back_seek_penalty 1  
   write $sd/queue/iosched/back_seek_max 16384  
   write $sd/queue/iosched/fifo_expire_sync 150  
   write $ss/queue/iosched/fifo_expire_async 1500  
   write $sd/queue/iosched/slice_idle 0  
   write $sd/queue/iosched/group_idle 8  
   write $sd/queue/iosched/low_latency 1  
   write $sd/queue/iosched/quantum 16
   write $sd/queue/iosched/slice_async 40  
   write $sd/queue/iosched/slice_async_rq 2  
   write $sd/queue/iosched/slice_sync 100  
   write $sd/queue/iosched/target_latencymax_time 300 
   done
fi

for sd in /sys/block/sd* ; do
    write $sd/queue/add_random "0"
    write $sd/queue/rotational "0"
    write $sd/queue/iostats "0"
done
for i in /sys/block/loop*; do
	  write $i/queue/add_random 0
	  write $i/queue/iostats 0
   	write $i/queue/nomerges 1
   	write $i/queue/rotational 0
   	write $i/queue/rq_affinity 1
done
for j in /sys/block/ram*; do
	write $j/queue/add_random 0
	write $j/queue/iostats 0
	write $j/queue/nomerges 1
	write $j/queue/rotational 0
   	write $j/queue/rq_affinity 1
done

echo **[ TCP TWEAKS ]**
sleep 0.1
algos=$(</proc/sys/net/ipv4/tcp_available_congestion_control);
if [[ $algos == *"westwood"* ]]
then
write /proc/sys/net/ipv4/tcp_congestion_control westwood

else
write /proc/sys/net/ipv4/tcp_congestion_control cubic
fi
write /proc/sys/net/ipv4/tcp_ecn 2
write /proc/sys/net/ipv4/tcp_dsack 1
write /proc/sys/net/ipv4/tcp_low_latency 1
write /proc/sys/net/ipv4/tcp_timestamps 1
write /proc/sys/net/ipv4/tcp_sack 1
write /proc/sys/net/ipv4/tcp_window_scaling 1

echo **[ GPU TWEAKS ]**
sleep 0.1
if [ -e "/sys/module/adreno_idler" ]; then
	write /sys/module/adreno_idler/parameters/adreno_idler_active "Y"
	write /sys/module/adreno_idler/parameters/adreno_idler_idleworkload "11000"
fi

echo **[ Misc Tweaks ]**
# Power Efficient
if [ -e "/sys/module/workqueue/parameters/power_efficient" ]; then
chmod 644 /sys/module/workqueue/parameters/power_efficient
write /sys/module/workqueue/parameters/power_efficient "Y"
chmod 444 /sys/module/workqueue/parameters/power_efficient

# High impedance
if [ -e "/sys/module/snd_soc_wcd9xxx/parameters/impedance_detect_en" ]; then
chmod 644 /sys/module/snd_soc_wcd9xxx/parameters/impedance_detect_en 
write /sys/module/snd_soc_wcd9xxx/parameters/impedance_detect_en 1
chmod 444 /sys/module/snd_soc_wcd9xxx/parameters/impedance_detect_en 

# High perf mode audio
if [ -e "/sys/module/snd_soc_wcd9330/parameters/high_perf_mode" ]; then
	write /sys/module/snd_soc_wcd9330/parameters/high_perf_mode 1
	
# Multi queue
if [ -e "/sys/module/scsi_mod/parameters/use_blk_mq" ]; then
	write /sys/module/scsi_mod/parameters/use_blk_mq Y
	
# DMA buffer
if [ -e "/sys/module/sys/module/snd_pcm/parameters/maximum_substreams" ]; then
	write /sys/module/sys/module/snd_pcm/parameters/maximum_substreams 8
fi

# Enable fast USB charging
if [ -e "/sys/KERNEL/FAST_CHARGE/force_fast_charge" ]; then
write /sys/KERNEL/FAST_CHARGE/force_fast_charge 1

# Disable Gentle Fair Sleepers
if [ -e "/sys/kernel/debug/sched_features" ]; then
write /sys/kernel/debug/sched_features NO_GENTLE_FAIR_SLEEPERS
write /sys/kernel/debug/sched_features NO_NEW_FAIR_SLEEPERS
write /sys/kernel/debug/sched_features NO_NORMALIZED_SLEEPER

echo Blocking wakelocks
sleep 0.1
if [ -e "/sys/module/wakeup/parameters/enable_msm_hsic_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_msm_hsic_ws
write /sys/module/wakeup/parameters/enable_msm_hsic_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_msm_hsic_ws
fi
if [ -e "/sys/module/wakeup/parameters/wlan_ctrl_wake" ]; then
chmod 644 /sys/module/wakeup/parameters/wlan_ctrl_wake
write /sys/module/wakeup/parameters/wlan_ctrl_wake 0
chmod 444 /sys/module/wakeup/parameters/wlan_ctrl_wake
fi
if [ -e "/sys/module/wakeup/parameters/wlan_rx_wake" ]; then
chmod 644 /sys/module/wakeup/parameters/wlan_rx_wake
write /sys/module/wakeup/parameters/wlan_rx_wake 0
chmod 444 /sys/module/wakeup/parameters/wlan_rx_wake
fi
if [ -e "/sys/module/wakeup/parameters/wlan_wake" ]; then
chmod 644 /sys/module/wakeup/parameters/wlan_wake
write /sys/module/wakeup/parameters/wlan_wake 0
chmod 444 /sys/module/wakeup/parameters/wlan_wake
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_si_ws
write /sys/module/wakeup/parameters/enable_si_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_si_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_si_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_si_ws
write /sys/module/wakeup/parameters/enable_si_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_si_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_bluedroid_timer_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_bluedroid_timer_ws
write /sys/module/wakeup/parameters/enable_bluedroid_timer_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_bluedroid_timer_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_ipa_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_ipa_ws
write /sys/module/wakeup/parameters/enable_ipa_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_ipa_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_netlink_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_netlink_ws
write /sys/module/wakeup/parameters/enable_netlink_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_netlink_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_netmgr_wl_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_netmgr_wl_ws
write /sys/module/wakeup/parameters/enable_netmgr_wl_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_netmgr_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws
write /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_qcom_rx_wakelock_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_timerfd_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_timerfd_ws
write /sys/module/wakeup/parameters/enable_timerfd_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_timerfd_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws
write /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_wlan_extscan_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_rx_wake_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws
write /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_wlan_rx_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wake_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_wlan_wake_ws
write /sys/module/wakeup/parameters/enable_wlan_wake_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_wlan_wake_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_wow_wl_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
write /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_wlan_wow_wl_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_wlan_ws
write /sys/module/wakeup/parameters/enable_wlan_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_wlan_ws
fi
if [ -e "/sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws" ]; then
chmod 644 /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws
write /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws 0
chmod 444 /sys/module/wakeup/parameters/enable_wlan_ctrl_wake_ws
fi
# Clean-up
echo cache cleaning...
sleep 0.1
find /data/data/*/cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/*/cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/*/*/cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/*/*/*/cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/Cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/*/Cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/*/*/Cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
find /data/data/*/*/*/*/Cache/ -depth -mindepth 1 -exec rm -Rf {} \;
sleep 0.1
rm -Rf /data/data/com.facebook.katana/files/video-cache/*
# Google service drain fix
echo Google Services drain fix..
sleep 0.1
su -c "pm enable com.google.android.gms"
sleep 0.1
su -c "pm enable com.google.android.gsf"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateActivity"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$Receiver"
sleep 0.1
su -c "pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateActivity"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver"
sleep 0.1
su -c "pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver"

start perfd
echo ===================================
echo ***[ TweakMod Successfully Applied! ]***
echo ===================================
echo ""
echo " Done, Enjoy.."
exit 0
