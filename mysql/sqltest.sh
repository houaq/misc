:
[ "$1" = start ] || exit 0

stop_mysql() {
	/opt/etc/init.d/S70mariadbd stop
	sync
#	md5sum /opt/var/mysql/ib*
	cd /tmp
	ejall
	sleep 5
	reboot
}

while :; do         
	sleep 20
	/opt/bin/mysqlslap \
        --iterations=10 \
        --concurrency=10  \
        --number-int-cols=5  \
        --number-char-cols=15  \
        --auto-generate-sql \
        --auto-generate-sql-add-autoincrement \
        --engine=innodb \
        --number-of-queries=10  \
        --create-schema=dbtest \
        -uroot -padmin || exit 1
	/opt/bin/mysqlslap \
        --iterations=10 \
        --concurrency=10  \
        --number-int-cols=5  \
        --number-char-cols=15  \
        --auto-generate-sql \
        --auto-generate-sql-add-autoincrement \
        --engine=innodb \
        --number-of-queries=10  \
        --create-schema=dbtest \
        -uroot -padmin || exit 1
	stop_mysql
#	mdev_sd sda1 add
done
