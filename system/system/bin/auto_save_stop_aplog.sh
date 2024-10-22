#!/system/bin/sh

# Add by wangwq14
# This shell will record logs to aplog dir.
# This shell will run when system first boot, such as after qfile burn, factoryreset, OTA.
# This shell is related to aplog.sh,  copy_aplog.sh, init.xuilog.rc.
# This shell will record it history to file /data/vendor/local/aplog/auto_save_stop_aplog.history.
# history: 2016-12-02, wwqing14, initial version

LOGFILE=/data/local/newlog/aplog/auto_save_stop_aplog.history
MAIN_LOG_STATUS=stopped
KERNEL_LOG_STATUS=stopped
QSEE_LOG_STATUS=stopped
LOG_STATUS_CHANGED=no

mkdir -p /data/local/newlog/aplog
date  > $LOGFILE
echo "mkdir /data/local/newlog/aplog done" >> $LOGFILE
echo "" >> $LOGFILE

if [ -n "$(getprop persist.log.tag.firstbootfinish)" ]; then
  if [ $(getprop persist.log.tag.firstbootfinish) = 1 ]; then
    echo "persist.log.tag.firstbootfinish is 1, exit." >> $LOGFILE
    return
  fi
else
  echo "persist.log.tag.firstbootfinish is not set, set to default value 1" >> $LOGFILE
  setprop persist.log.tag.firstbootfinish 1
fi

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30;
do
  echo "xxx This is $i times test "
  date  >> $LOGFILE

  # log service which should be started by aplog.sh
  if [ -n "$(getprop persist.log.tag.aplog.mainlog)" ]; then
    if [ $(getprop persist.log.tag.aplog.mainlog) = "true" ]; then
      echo "mainlog is running." >> $LOGFILE
      MAIN_LOG_STATUS=running
    else
      echo "mainlog is stopped" >> $LOGFILE
      MAIN_LOG_STATUS=stopped
    fi
  else
    echo "mainlog not run" >> $LOGFILE
    MAIN_LOG_STATUS=stopped
  fi

  if [ -n "$(getprop persist.log.tag.aplog.kernellog)" ]; then
    if [ $(getprop persist.log.tag.aplog.kernellog) = "true" ]; then
      echo "kernellog is running." >> $LOGFILE
      KERNEL_LOG_STATUS=running
    else
      echo "kernellog is stopped" >> $LOGFILE
      KERNEL_LOG_STATUS=stopped
    fi
  else
    echo "kernellog not run" >> $LOGFILE
    KERNEL_LOG_STATUS=stopped
  fi


  if [ "$MAIN_LOG_STATUS" = "stopped" ]; then
    echo "mainlog services stopped, return shell right now." >> $LOGFILE
    return
  fi

  if [ "$KERNEL_LOG_STATUS" = "stopped" ]; then
    echo "kernellog services stopped, return shell right now." >> $LOGFILE
    return
  fi

  for svc in batterylog mainlog_big radiolog radiolog_big eventslog eventslog_big;
  do
    if [ -n "$(getprop persist.log.tag.aplog.$svc)" ]; then
      if [ $(getprop persist.log.tag.aplog.$svc) = "true" ]; then
       echo "$svc is running." >> $LOGFILE
       LOG_STATUS_CHANGED=yes
      fi
    else
      echo "$svc not run" >> $LOGFILE
    fi
  done

  if [ "$LOG_STATUS_CHANGED" = "yes" ]; then
    echo "log services changed by 3333 or feedback, return shell right now." >> $LOGFILE
    return
  fi

  echo "sleep 10 seconds ..." >> $LOGFILE
  echo  "" >> $LOGFILE
  sleep 10
done

date  >> $LOGFILE
stop mainlog
setprop persist.log.tag.aplog.mainlog false
echo "mainlog stopped by timeout" >> $LOGFILE
stop kernellog
setprop persist.log.tag.aplog.kernellog false
echo "kernellog stopped by timeout" >> $LOGFILE
echo "" >> $LOGFILE
wait

date  >> $LOGFILE
echo "auto_save_stop_aplog finish. Bye-Bye" >> $LOGFILE
