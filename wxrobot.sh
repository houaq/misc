:
curl -H 'Content-type: application/json' \
	-d '{"msgtype":"markdown","markdown":{ "content":"## Hello, world!\n**This is a message from Mars, and I am Boybot.**"}}' \
	https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=c3a799d0-1f63-4cbb-b730-a010497b0dcd
