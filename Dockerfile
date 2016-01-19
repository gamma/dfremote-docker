FROM heroku/cedar:14
MAINTAINER pronvit@me.com

# Install Dwarf Fortress dependencies
# 64 bit linux, but DF requires 32 bit libraries
RUN dpkg --add-architecture i386 && apt-get update -y \
    && apt-get install -y \
    libsdl-image1.2:i386 libsdl-ttf2.0-0:i386 libgtk2.0-0:i386 libglu1-mesa:i386

# Setup en_US.UTF-8 locale (so we can see _all_ DF's ASCII)
#ENV LANG en_US.UTF-8
#RUN apt-get -y install locales && locale-gen en_US.UTF-8

# Install wget (to download DF and DFHack)
RUN apt-get install -y wget unzip nmap net-tools

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && mkdir -p /app/user

# Download & Unpack Dwarf Fortress
RUN wget --no-check-certificate -qO- http://www.bay12games.com/dwarves/df_40_24_linux.tar.bz2 | tar -xj -C /app/user && rm /app/user/libs/libstdc++.so.6

# Download & Unpack DFHack
RUN wget --no-check-certificate -qO- https://github.com/DFHack/dfhack/releases/download/0.40.24-r5/dfhack-0.40.24-r5-Linux-gcc-4.5.4.tar.bz2 | tar -xj -C /app/user && rm -rf df_linux/hack/plugins/*

RUN wget -q http://mifki.com/df/update/dfremote-updater.zip && unzip -j -d /app/user/hack/plugins dfremote-updater.zip 0.40.24-r5/linux/* && rm dfremote-updater.zip
RUN wget -q http://mifki.com/df/update/dfremote-latest.zip && mkdir t && unzip -d t dfremote-latest.zip && mv t/0.40.24-r5/linux/* /app/user/hack/plugins/ && mv t/remote /app/user/hack/lua/ && rm -rf t && rm dfremote-latest.zip

ADD init.txt /app/user/data/init/init.txt
ADD dfhack.init /app/user/dfhack.init

WORKDIR /app/user

EXPOSE 1235/udp

RUN mkdir /app/user/data/save
VOLUME /app/user/data/save

CMD /app/user/dfhack

