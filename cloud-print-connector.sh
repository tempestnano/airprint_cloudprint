#! /bin/sh
### BEGIN INIT INFO
# Provides:          cloud-print-connector
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Should-Start:      $network avahi-daemon
# Should-Stop:       $network
# X-Start-Before:
# X-Stop-After:
# Default-Start:     2 3 4 5
# Default-Stop:      1
# Short-Description: CUPS Cloud Print Connector
# Description:       Poll for Cloud Print Jobs
### END INIT INFO

# Author: Ulrich Hahn

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
OPTS='--config-filename /etc/cloud-print-connector/gcp-cups-connector.config.json'
DAEMON=/opt/cloud-print-connector
NAME=gcp-cups-connector
PIDFILE=/var/run/$NAME/$NAME.pid
DESC="Google Cloud Print Connector"
SCRIPTNAME=/etc/init.d/cloud-print-connector
USER=cloud-print-connector

unset TMPDIR

# Exit if the package is not installed
test -x $DAEMON || exit 0

. /lib/lsb/init-functions

# Get the timezone set.
if [ -z "$TZ" -a -e /etc/timezone ]; then
    TZ=`cat /etc/timezone`
    export TZ
fi


case "$1" in
  start)
        log_daemon_msg "Starting $DESC" "$NAME"

        mkdir -p `dirname "$PIDFILE"`

        start-stop-daemon --make-pidfile --background --chuid $USER --start --oknodo --pidfile "$PIDFILE" --exec $DAEMON -- $OPTS
        status=$?
        log_end_msg $status
        ;;
  stop)
        log_daemon_msg "Stopping $DESC" "$NAME"
        start-stop-daemon --stop --quiet --retry 5 --oknodo --exec $DAEMON
        status=$?
        log_end_msg $status
        ;;
  reload|force-reload)
       log_daemon_msg "Reloading $DESC" "$NAME"
       start-stop-daemon --stop --quiet --exec $DAEMON --signal 1
       status=$?
       log_end_msg $status
       ;;
  restart)
        log_daemon_msg "Restarting $DESC" "$NAME"
        if start-stop-daemon --stop --quiet --retry 5 --oknodo --exec $DAEMON -- $OPTS; then
                start-stop-daemon --chuid $USER --start --quiet --pidfile "$PIDFILE" --exec $DAEMON $OPTS &
        fi
        status=$?
        log_end_msg $status
        ;;
  status)
        status_of_proc -p "$PIDFILE" "$DAEMON" "$NAME" && exit 0 || exit $?
        ;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload|status}" >&2
        exit 3
        ;;
esac

exit 0