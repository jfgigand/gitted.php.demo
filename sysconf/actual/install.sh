# Installer script for sysconf "actual"  -*- shell-script -*-

. /usr/lib/sysconf.base/common.sh

# A few settings
# (commented out as we're using clipperz-legacy)
# GITTED_CLIPPERZ_ROOT_DIR=/var/lib/clipperz
# GITTED_CLIPPERZ_UPSTREAM_URL=https://github.com/clipperz/password-manager.git
# GITTED_CLIPPERZ_UPSTREAM_REF=release.2014.06.21

mysql_run() {
    echo "MySQL query: $1" >&2
    echo "$1" >&2
    echo "$1" | mysql
    local _status=${PIPESTATUS[1]}
    if [ $_status -ne 0 ]; then
        nef_fatal "MySQL query failed with status $_status"
    fi
}

# Install required Debian packages
_packages=
_packages="$_packages nginx mysql-server"
_packages="$_packages php5-fpm php5-cli php5-mysql"      # for PHP back-end
sysconf_require_packages $_packages

# Fix Nginx
_force_nginx_restart=no
if [ -r /etc/nginx/sites-enabled/default ]; then
    rm -f /etc/nginx/sites-enabled/default
    _force_nginx_restart=yes
fi
if ps x | grep nginx | grep -vq grep; then
    if [ $_force_nginx_restart = yes ]; then
        service nginx restart
    fi
else
    service nginx start
fi

# Fix php-fpm
_force_fpm_restart=no
if [ -r /etc/php5/fpm/pool.d/www.conf ]; then
    rm -f /etc/php5/fpm/pool.d/www.conf
    _force_fpm_restart=yes
fi
if ps x | grep php-fpm | grep -vq grep; then
    if [ $_force_fpm_restart = yes ]; then
        service php5-fpm restart
    fi
else
    service php5-fpm start
fi


# Create MySQL database and user for demo
mysql_run "CREATE DATABASE IF NOT EXISTS demo"
_count=$(mysql_run "SELECT User FROM mysql.user WHERE User = 'demo'" | grep ^demo | wc -l)
if [ $_count -eq 0 ]; then
    mysql_run "CREATE USER 'demo'@'%' IDENTIFIED BY 'demo'"
    mysql_run "GRANT ALL PRIVILEGES ON demo.* TO 'demo' "
    mysql_run "FLUSH PRIVILEGES"
fi
_count=$(echo "SHOW TABLES" | mysql demo | tail -n +2 | wc -l)
if [ $_count -eq 0 ]; then
    echo "Populating MySQL database: demo"
    # cat /var/lib/demo-legacy/database.structure.sql | mysql demo
fi
