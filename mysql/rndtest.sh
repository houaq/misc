:
[ "$1" = start ] || exit 0
SUMFILE=/opt/var/sum
RNDFILE=/opt/var/rnd
[ -f $SUMFILE ] && {
	sum=`cat $SUMFILE`
	md5sum $RNDFILE | grep $sum || echo 'File corrupted!'
	exit 1
}
dd if=/dev/urandom of=$RNDFILE bs=8192 count=1024
md5sum $RNDFILE | cut -d' ' -f1 >$SUMFILE
reboot
