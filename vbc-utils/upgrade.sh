:
rm -f all.txt failed.txt
for ip in `./wwho`
do
	echo $ip >>all.txt
	./espota.py -i $ip -r -f firmware.bin || \
	./espota.py -i $ip -r -f firmware.bin || \
	./espota.py -i $ip -r -f firmware.bin || \
	echo $ip >>failed.txt
done
