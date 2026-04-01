#!/bin/sh
### BEGIN INIT INFO
# Provides:          powertune
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       PowerTune Digital Dashboard (administrative control)
### END INIT INFO

# The app is launched by init(8) via the inittab respawn entry for
# /opt/PowerTune/powertune-launcher.  This init.d script provides
# administrative stop/restart control for development and deployment.

MAINT_FLAG=/tmp/powertune-maintenance

case "$1" in
    start)
        rm -f "${MAINT_FLAG}"
        echo "PowerTune will start on next respawn cycle."
        ;;
    stop)
        touch "${MAINT_FLAG}"
        killall PowerTuneQMLGui 2>/dev/null || true
        echo "PowerTune stopped (maintenance mode)."
        ;;
    restart)
        "$0" stop
        sleep 2
        "$0" start
        ;;
    status)
        if pgrep -f PowerTuneQMLGui > /dev/null 2>&1; then
            echo "PowerTune is running."
        else
            echo "PowerTune is not running."
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
