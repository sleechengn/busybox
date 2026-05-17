from scratch
add ./busybox.1.35.0-x86_64-linux-musl /usr/bin/busybox
run ["/usr/bin/busybox","mkdir","/bin"]
run ["/usr/bin/busybox","--install","/bin"]
env PATH=/bin:/usr/bin
env SHELL=/bin/sh
entrypoint ["/bin/sh"]
