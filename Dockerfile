from debian:trixie as fetch
run apt update
run apt install -y aria2 curl
run set -e \
	&& aria2c -x 10 -j 10 -k 1M -o /opt/busybox https://busybox.net/downloads/binaries/1.35.0-x86_64-linux-musl/busybox
run set -e \
	&& chmod +x /opt/busybox
run set -e \
       && DOWNLOAD=$(curl -s https://api.github.com/repos/tsl0922/ttyd/releases/latest | grep browser_download_url |grep ttyd.x86_64| cut -d'"' -f4) \
       && aria2c -x 10 -j 10 -k 1m $DOWNLOAD -o /opt/ttyd.x86_64 \
       && chmod +x /opt/ttyd.x86_64
run mkdir /tmp/filebrowser \
        && cd /tmp/filebrowser\
        && DOWNLOAD=$(curl -s https://api.github.com/repos/filebrowser/filebrowser/releases/latest | grep browser_download_url |grep linux|grep amd64| grep -v rocm| cut -d'"' -f4) \
        && aria2c -x 10 -j 10 -k 1M $DOWNLOAD -o linux-amd64-filebrowser.tar.gz \
        && tar -zxvf linux-amd64-filebrowser.tar.gz \
        && rm -rf linux-amd64-filebrowser.tar.gz \
        && ln -s $(pwd)/filebrowser /opt/filebrowser

from scratch as busybox
copy --from=fetch /opt/busybox /usr/bin/busybox
copy --from=fetch /opt/ttyd.x86_64 /usr/bin/ttyd.x86_64
copy --from=fetch /opt/filebrowser /usr/bin/filebrowser

run ["/usr/bin/busybox","mkdir","/bin"]
run ["/usr/bin/busybox","--install","/bin"]
env PATH=/bin:/usr/bin
env SHELL=/bin/sh

from busybox as dev
run mkdir /opt
run mkdir /opt/filebrowser

run echo "#!/bin/sh" > /entrypoint.sh \
	&& echo "nohup filebrowser -d /opt/filebrowser/filebrowser.db -a 0.0.0.0 -p 8081 -b /filebrowser -r / --noauth > /dev/null &" >> /entrypoint.sh \
	&& echo "nohup ttyd.x86_64 --port 8082 --writable --base-path /ttyd -t enableZmodem=true -t enableTrzsz=true /usr/bin/busybox sh > /dev/null &" >> /entrypoint.sh \
	&& echo "tail -f /dev/null" >> /entrypoint.sh \
	&& chmod +x /entrypoint.sh
entrypoint ["/bin/sh","/entrypoint.sh"]
