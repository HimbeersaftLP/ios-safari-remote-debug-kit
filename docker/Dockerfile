FROM ubuntu:latest

LABEL org.opencontainers.image.authors="Tyler Akins <fidian@rumkin.com>"

ENV LC_ALL=C

WORKDIR /opt/

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt install -y \
		autoconf \
		automake \
		build-essential \
		checkinstall \
		curl \
		git \
		libcurl4-gnutls-dev \
		libssl-dev \
		libtool \
		libtool-bin \
		libusb-dev \
		libusb-1.0-0-dev \
		nodejs \
		npm \
		pkg-config \
		psmisc \
		systemd \
		udev \
		usbmuxd && \
	apt-get clean

RUN git clone https://github.com/libimobiledevice/libplist.git && \
	cd libplist && \
	./autogen.sh --without-cython && \
	make && \
	make install && \
	cd .. && \
	rm -rf libplist/

RUN git clone https://github.com/libimobiledevice/libimobiledevice-glue.git && \
	cd libimobiledevice-glue && \
	./autogen.sh --without-cython && \
	make && \
	make install && \
	cd .. && \
	rm -rf libimobiledevice-glue/

RUN git clone https://github.com/libimobiledevice/libusbmuxd.git && \
	cd libusbmuxd && \
	./autogen.sh --without-cython && \
	make && \
	make install && \
	ldconfig && \
	cd .. && \
	rm -rf libusbmuxd/

RUN git clone https://github.com/libimobiledevice/libtatsu.git && \
	cd libtatsu && \
	./autogen.sh --without-cython && \
	make && \
	make install && \
	cd .. && \
	rm -rf libtatsu/

RUN git clone https://github.com/libimobiledevice/libimobiledevice.git && \
	cd libimobiledevice && \
	./autogen.sh && \
	make && \
	make install && \
	ldconfig && \
	cd .. && \
	rm -rf libimobiledevice/

RUN git clone https://github.com/libimobiledevice/usbmuxd.git && \
	cd usbmuxd && \
	./autogen.sh && \
	make && \
	make install && \
	ldconfig && \
	cd .. && \
	rm -rf usbmuxd/

RUN git clone https://github.com/google/ios-webkit-debug-proxy.git && \
	cd ios-webkit-debug-proxy && \
	./autogen.sh && \
	make && \
	make install && \
	ldconfig && \
	cd .. && \
	rm -rf ios-webkit-debug-proxy/

RUN git clone https://github.com/HimbeersaftLP/ios-safari-remote-debug-kit.git && \
	cd ios-safari-remote-debug-kit/src && \
	yes "" | ./generate.sh

COPY ./entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
