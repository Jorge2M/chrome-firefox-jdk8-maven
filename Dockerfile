FROM ubuntu:20.04

RUN apt-get update -y \
	&& apt -y install locales \
	&& apt-get install -y wget \
	&& apt-get install -y gnupg2 \
	&& apt-get -qqy dist-upgrade \
	&& apt-get -y install curl \
	&& apt-get -qqy install software-properties-common gettext-base unzip \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#=======
# Java 8
#=======
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8 
RUN add-apt-repository ppa:ts.sch.gr/ppa \
	&& apt-get update \
	&& echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
	&& dpkg --configure -a \
	&& apt-get install openjdk-8-jdk-headless -y --force-yes \
	&& rm /etc/java-8-openjdk/accessibility.properties

#============
# Maven
#============
#RUN wget --no-verbose -O /tmp/apache-maven-3.8.3-bin.tar.gz http://www-eu.apache.org/dist/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz && \
#    tar xzf /tmp/apache-maven-3.8.3-bin.tar.gz -C /opt/ && \
#    ln -s /opt/apache-maven-3.8.3 /opt/maven && \
#    ln -s /opt/maven/bin/mvn /usr/local/bin  && \
#    rm -f /tmp/apache-maven-3.8.3-bin.tar.gz
RUN apt-get install maven -y

#=======
# Chrome
#=======
#List of versions in https://www.ubuntuupdates.org/ppa/google_chrome
ARG CHROME_VERSION=96.0.4664.110-1  
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
	&& apt-get update -qqy \
	&& apt-get -qqy install google-chrome-stable=$CHROME_VERSION \
	&& rm /etc/apt/sources.list.d/google-chrome.list \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
	&& sed -i 's/"$HERE\/chrome"/"$HERE\/chrome" --no-sandbox/g' /opt/google/chrome/google-chrome

#========= 
# Firefox
#========= 
#List of versions in https://download-installer.cdn.mozilla.net/pub/firefox/releases/
ARG FIREFOX_VERSION=95.0
RUN FIREFOX_DOWNLOAD_URL=$(if [ $FIREFOX_VERSION = "latest" ] || [ $FIREFOX_VERSION = "nightly-latest" ] || [ $FIREFOX_VERSION = "devedition-latest" ]; then echo "https://download.mozilla.org/?product=firefox-$FIREFOX_VERSION-ssl&os=linux64&lang=en-US"; else echo "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2"; fi) \
  && apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install firefox \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && wget --no-verbose -O /tmp/firefox.tar.bz2 $FIREFOX_DOWNLOAD_URL \
  && apt-get -y purge firefox \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 \
  && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox
 
RUN apt-get update -qqy \
	&& apt-get -qqy install xvfb \
	&& rm -rf /var/lib/apt/lists/* /var/cache/apt/*
