#!/bin/sh
### BEGIN INIT INFO
# Provides:          powertune
# Required-Start:    $local_fs $network $syslog
# Required-Stop:     $local_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       PowerTune Digital Dashboard
### END INIT INFO

export HOME=/home/root
export LC_ALL=en_US.utf8
export QT_QPA_EGLFS_HIDECURSOR=1
export QT_QPA_EGLFS_ALWAYS_SET_MODE=1
export QT_QPA_EGLFS_KMS_ATOMIC=1
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_KMS_CONFIG=/opt/PowerTune/kms-config.json

APP_DIR=/opt/PowerTune
APP_BIN=${APP_DIR}/PowerTuneQMLGui
APP_LOG=/var/log/powertune.log

case "$1" in
    start)
        echo "Starting PowerTune..."

        if [ -f /tmp/splash.pid ]; then
            SPID=$(cat /tmp/splash.pid)
            while kill -0 "$SPID" 2>/dev/null; do
                sleep 0.2
            done
            rm -f /tmp/splash.pid
        fi

        cd "${APP_DIR}" || exit 1
        if [ -x "${APP_BIN}" ]; then
            "${APP_BIN}" -platform eglfs > "${APP_LOG}" 2>&1 &
        else
            echo "PowerTuneQMLGui not found at ${APP_BIN}"
            exit 1
        fi
        ;;
    stop)
        echo "Stopping PowerTune..."
        killall PowerTuneQMLGui 2>/dev/null || true
        killall Generic 2>/dev/null || true
        ;;
    restart)
        "$0" stop
        sleep 1
        "$0" start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
