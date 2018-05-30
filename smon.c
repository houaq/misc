#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/select.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <signal.h>

static int quit = 0;
static int hex_out = 0;

/* convert @data to a hex string */
static char *tohex(unsigned char *data, int len)
{
	static char hexstr[BUFSIZ];
	char *p;
	
	p = hexstr;
	while (len-- > 0) {
		*p++ = ((*data >> 4) & 0x0f) + '0';
		*p++ = (*data & 0x0f) + '0';
		data++;
	}
	*p = '\0';

	return hexstr;
}

int rawmode(int fd, char *speed, struct termios *old_p)
{
	struct termios tio;
	int rc;
	static struct {
		char *speed;
		speed_t index;
	} btable[] = {
		{"2400", B2400},
		{"9600", B9600},
		{"19200", B19200},
		{"38400", B38400},
		{"115200", B115200},

		{NULL, 0}
	};

	rc = tcgetattr(fd, old_p);
	if (rc < 0) {
		perror("tcgetattr");
		return rc;
	}

	memcpy(&tio, old_p, sizeof(tio));
#ifdef linux
	cfmakeraw(&tio);
#else
	tio.c_iflag &= ~(ISTRIP|ICRNL|INLCR);
	tio.c_oflag &= ~(OPOST|OCRNL|ONLCR);
	tio.c_lflag &= ~(ISIG|ICANON|ECHO);
	tio.c_cc[VMIN] = 1;
#endif
	if (speed) {
		int baud = B9600;
		int i;

		for (i = 0; btable[i].speed; i++) {
			if (!strcmp(speed, btable[i].speed)) {
				baud = btable[i].index;
				break;
			}
		}
		cfsetispeed(&tio, baud);
		cfsetospeed(&tio, baud);
	}

	rc = tcsetattr(fd, TCSAFLUSH, &tio);
	if (rc < 0) {
		perror("tcgetattr");
		return rc;
	}
	return 0;
}

void serial_mon(int fd)
{
	struct termios old_tio;
	char buf[128];

	if (isatty(0))
		rawmode(0, NULL, &old_tio);

	while (!quit) {
		fd_set fds;
		int rc;

		FD_ZERO(&fds);
		FD_SET(0, &fds);
		FD_SET(fd, &fds);

		rc = select(fd + 1, &fds, NULL, NULL, NULL);
		switch (rc) {
		case -1:
			perror("select");
		case 0:
			break;
		default:
			if (FD_ISSET(0, &fds)) {
				rc = read(0, buf, 128);
				if (memchr(buf, '', rc))
					quit = 1;
				else
					write(fd, buf, rc);
			}
			if (FD_ISSET(fd, &fds)) {
				rc = read(fd, buf, 128);
				if (hex_out)
					puts(tohex(buf, rc));
				else
					write(1, buf, rc);
			}
			break;
		}
	}

	if (isatty(0))
		tcsetattr(0, TCSAFLUSH, &old_tio);
}

int main(int argc, char **argv)
{
	struct termios old_tio;
	int fd;
	char *speed = "9600";

	if (argc < 2) {
		puts("Usage: smon <dev>");
		exit(0);
	}
	fd = open(argv[1], O_RDWR);
	if (fd < 0) {
		perror("open");
		exit(1);
	}

	if (argc > 2)
		speed = argv[2];

	if (argc > 3)
		hex_out = 1;

	rawmode(fd, speed, &old_tio);
	printf("Monitoring %s..., Press [CTRL-C] to quit\n", argv[1]);
	serial_mon(fd);

	tcsetattr(fd, TCSAFLUSH, &old_tio);
	return 0;
}

