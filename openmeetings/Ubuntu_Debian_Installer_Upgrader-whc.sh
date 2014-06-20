#!/bin/bash
# OpenMeetings 2.0 Automatic Installer and Updater
# Version: 3
# Date: 02/08/2012
# Includes a Menu to choose between upgrade 2.1 or fresh install of 2.0
# Stephen Cottham
#
# Report any problems to the usual mail-list
#
mkdir /tmp/.ivy2
ln -s /tmp/.ivy2
USERNAME=coopadmin
PASSWORD=Zrr1g1M5wUp3CeImh63k
while :
do
clear
echo "**************************"
echo "* OpenMeetings Installer *"
echo "**************************"
echo "* [1] Ubuntu Install"
echo "* [2] Debian Install"
echo "* [3] Upgrade"
echo "* [0] Exit"
echo "**************************"
echo -n "Enter your menu choice [1, 2, 3 or 4]: "
read yourch
case $yourch in

1) clear 
echo "Installing Fresh OpenMeetings 2.0 (Ubuntu)"
echo
sleep 1
echo "Creating Working Directory.................................................................."
echo
sleep 1
if ! [ -d "/usr/adm" ]; then
mkdir /usr/adm;
fi

sleep 5 && clear
echo "Updating Repos and Installing Java 6.............................................................................."
echo
sleep 1
apt-get update
apt-get install unzip subversion vim build-essential expect -y
cd /usr/adm
wget -c --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" \
http://download.oracle.com/otn-pub/java/jdk/6u32-b05/jdk-6u32-linux-x64.bin
cd /usr/adm
chmod +x jdk-6u32-linux-x64.bin
./jdk-6u32-linux-x64.bin
mkdir -p /usr/lib/jvm
mv /usr/adm/jdk1.6.0_32 /usr/lib/jvm/

#expect Enter
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_32/bin/javac 1
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_32/bin/java 1
update-alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/jdk1.6.0_32/bin/javaws 1
update-alternatives --config javac
update-alternatives --config java
update-alternatives --config javaws

sleep 5 && clear
echo "Installing OpenOffice and Build Tools............................................................................"
echo
sleep 1

apt-get install openoffice.org-writer openoffice.org-calc openoffice.org-impress -y
apt-get install openoffice.org-draw openoffice.org-math imagemagick sox -y
apt-get install libgif-dev xpdf libfreetype6 libfreetype6-dev libjpeg62 libjpeg8 -y
apt-get install libjpeg8-dev libjpeg-dev libdirectfb-dev -y
apt-get install libart-2.0-2 libt1-5 zip unzip bzip2 subversion git-core -y
apt-get install yasm texi2html libfaac-dev libfaad-dev libmp3lame-dev libsdl1.2-dev libx11-dev -y
apt-get install libxfixes-dev libxvidcore-dev zlib1g-dev libogg-dev sox libvorbis0a libvorbis-dev -y
apt-get install libgsm1 libgsm1-dev libfaad2 flvtool2 lame make g++ -y

sleep 5 && clear
echo "Installing SWFTools.............................................................................................."
echo
sleep 1
cd /usr/adm
wget -c http://www.swftools.org/swftools-2012-04-08-0857.tar.gz
tar -zxvf swftools-2012-04-08-0857.tar.gz
cd swftools-2012-04-08-0857
./configure
make
make install

sleep 5 && clear
echo "Installing FFMpeg..............................................................................................."
echo
sleep 1
cd /usr/adm
wget -c http://ffmpeg.org/releases/ffmpeg-0.11.1.tar.gz
tar -zxvf ffmpeg-0.11.1.tar.gz
cd ffmpeg-0.11.1
./configure --enable-libmp3lame --enable-libxvid --enable-libvorbis \
--enable-libgsm --enable-libfaac --enable-gpl --enable-nonfree
make
make install

sleep 5 && clear
echo "Installing MySQL Server...................................................................."
echo
sleep 1
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password $PASSWORD'
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password $PASSWORD'
apt-get -y install mysql-server

sleep 5 && clear
echo "Creating DB and setting Permissions......................................................."
echo
sleep 1
mysql -u root -p$PASSWORD -e "CREATE DATABASE openmeetings DEFAULT CHARACTER SET 'utf8';";
mysql -u root -p$PASSWORD -e "GRANT ALL PRIVILEGES ON openmeetings.* TO \"openmeetings\"@\"localhost\" IDENTIFIED BY \"$PASSWORD\" WITH GRANT OPTION;";

sleep 5 && clear
echo "Downloading and installing JODConverter......................................................"
echo
sleep 1

sleep 5 && clear
echo "Installing ApacheAnt......................................................................."
echo
sleep 1
cd /usr/adm
wget -c http://www.trieuvan.com/apache//ant/binaries/apache-ant-1.9.1-bin.tar.gz
tar -zxvf apache-ant-1.9.1-bin.tar.gz

sleep 5 && clear
echo "Checking out OM2.0........................................................................."
echo
sleep 1
cd /usr/adm
svn checkout http://svn.apache.org/repos/asf/openmeetings/branches/2.1/
cd /usr/adm/2.1

sleep 5 && clear
echo "Compiling and Installing OM 2.1............................................................"
echo
sleep 1
/usr/adm/apache-ant-1.9.1/bin/ant clean.all
/usr/adm/apache-ant-1.9.1/bin/ant -Ddb=mysql

cd /usr/adm/2.1/dist
mv red5/ /usr/lib/
cp -R /usr/adm/jodconverter-core-3.0-beta-4 /usr/lib/red5/webapps/openmeetings

sleep 5 && clear
echo "Setting up permissions and creating start-up scripts......................................."
echo
sleep 1
chown -R nobody /usr/lib/red5
chmod +x /usr/lib/red5/red5.sh
chmod +x /usr/lib/red5/red5-debug.sh

rm -f /etc/init.d/red5
touch /etc/init.d/red5
echo '#! /bin/sh
### BEGIN INIT INFO
# Provides: red5
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Starts red5 server for Openmeetings.
### END INIT INFO
# For RedHat and cousins:
# chkconfig: 2345 85 85
# description: Red5 flash streaming server for OpenMeetings
# processname: red5
# Created By: Sohail Riaz (sohaileo@gmail.com)
# Modified by Alvaro Bustos
PROG=red5
RED5_HOME=/usr/lib/red5
DAEMON=$RED5_HOME/$PROG.sh
PIDFILE=/var/run/$PROG.pid
[ -r /etc/sysconfig/red5 ] && . /etc/sysconfig/red5
RETVAL=0
case "$1" in
start)
cd $RED5_HOME
start-stop-daemon --start -c nobody --pidfile $PIDFILE \
--chdir $RED5_HOME --background --make-pidfile \
--exec $DAEMON >/dev/null 2>/dev/null &
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
echo $! > $PIDFILE
fi
echo
;;
stop)
start-stop-daemon --stop --quiet --pidfile $PIDFILE \
--name java
rm -f $PIDFILE
echo
[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/$PROG
;;
restart|force-reload)
$0 stop
$0 start
;;
status)
# Debian and Ubuntu 10 status check
ps aux | grep -f $PIDFILE >/dev/null 2>/dev/null && RETVAL=0 || RETVAL=3
# Ubuntu 12 status check using improved "start-stop-daemon" status query
# (use the above command, or comment out above command and uncomment the two
below commands.
# start-stop-daemon --status --pidfile $PIDFILE
# RETVAL=$?
[ $RETVAL -eq 0 ] && echo "$PROG is running"
[ $RETVAL -eq 1 ] && echo "$PROG is not running and the pid file exists"
[ $RETVAL -eq 3 ] && echo "$PROG is not running"
[ $RETVAL -eq 4 ] && echo "$PROG - unable to determine status"
;;
checkports)
netstat -anp | grep soffice
netstat -anp | grep java
;;
*)
echo $"Usage: $0 {start|stop|restart|force-reload|status|checkports}"
RETVAL=1
esac
exit $RETVAL
' >> /etc/init.d/red5

chmod +x /etc/init.d/red5
update-rc.d red5 defaults

sleep 5 && clear
echo "Setting up Om to use MYSQL backend................................................"
echo
sleep 1
mv /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml \
/usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml-ori
mv /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/mysql_persistence.xml \
/usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i "s/Username=root/Username=$USERNAME/g" /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i "s/Password=/Password=$PASSWORD/g" /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
/etc/init.d/red5 start

sleep 5 && clear
echo "Openmeetings is now installed please open a browser to:"
echo "http://<OMServerIPaddress>:5080/openmeetings/install"
echo
sleep 5
;;

2) clear 
echo "Installing Fresh OpenMeetings 2.0 (Debian)"
echo
sleep 1
echo "Creating Working Directory.................................................................."
echo
sleep 1
if ! [ -d "/usr/adm" ]; then
mkdir /usr/adm;
fi
echo "Backing up sources.list and adding new repos................................................"
echo
sleep 1
mv /etc/apt/sources.list /etc/apt/sources.old
touch /etc/apt/sources.list
echo "deb http://security.debian.org/ wheezy/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ wheezy/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://ftp.debian.org/debian/ wheezy main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.debian.org/debian/ wheezy main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.debian.org/debian/ wheezy-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://ftp2.de.debian.org/debian wheezy main non-free" >> /etc/apt/sources.list
echo "deb http://deb-multimedia.org wheezy main" >> /etc/apt/sources.list
apt-get update
apt-get install expect -y

sleep 5 && clear
echo "Installaing Java 6 (Sun)...................................................................."
echo
sleep 1
#apt-get install sun-java6-jdk -y
apt-get update
apt-get install unzip subversion vim build-essential expect -y
cd /usr/adm
wget -c --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F" http://download.oracle.com/otn-pub/java/jdk/6u32-b05/jdk-6u32-linux-x64.bin
cd /usr/adm
chmod +x jdk-6u32-linux-x64.bin
./jdk-6u32-linux-x64.bin
mkdir -p /usr/lib/jvm
mv /usr/adm/jdk1.6.0_32 /usr/lib/jvm/

#expect Enter
update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk1.6.0_32/bin/javac 1
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.6.0_32/bin/java 1
update-alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/jdk1.6.0_32/bin/javaws 1
update-alternatives --config javac
update-alternatives --config java
update-alternatives --config javaws


sleep 5 && clear
echo "Installing OpenOffice and needed pre-req's.................................................."
echo
sleep 1
apt-get install openoffice.org-writer openoffice.org-calc openoffice.org-impress \
openoffice.org-draw openoffice.org-math imagemagick gs-gpl -y
apt-get install libgif-dev xpdf php5 php5-mysql libfreetype6 libfreetype6-dev libjpeg8 libjpeg62 libjpeg8-dev -y
apt-get install g++ libjpeg-dev libdirectfb-dev libart-2.0-2 libt1-5 zip unzip bzip2 -y
apt-get install subversion git-core yasm texi2html libfaac-dev libfaad-dev -y
apt-get install libmp3lame-dev libsdl1.2-dev libx11-dev libxfixes-dev libxvidcore4-dev zlib1g-dev -y
apt-get install libogg-dev sox libvorbis0a libvorbis-dev libgsm1 libgsm1-dev libfaad2 subversion flvtool2 lame --force-yes -y

sleep 5 && clear
echo "Installing MySQL Server...................................................................."
echo
sleep 1
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password $PASSWORD'
debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password $PASSWORD'
apt-get -y install mysql-server

sleep 5 && clear
echo "Creating DB and setting Permissions......................................................."
echo
mysql -u root -p$PASSWORD -e "CREATE DATABASE openmeetings DEFAULT CHARACTER SET 'utf8';";
mysql -u root -p$PASSWORD -e "GRANT ALL PRIVILEGES ON openmeetings.* TO \"openmeetings\"@\"localhost\" IDENTIFIED BY \"$PASSWORD\" WITH GRANT OPTION;";


sleep 5 && clear
echo "Compiling and installing SWFTools........................................................."
echo
sleep 1
wget -c http://www.swftools.org/swftools-2012-04-08-0857.tar.gz
tar -zxvf swftools-2012-04-08-0857.tar.gz
cd swftools-2012-04-08-0857
./configure
make
make install

sleep 5 && clear
echo "Compiling and installing FFMpeg..........................................................."
echo
sleep 1
cd /usr/adm
wget -c http://ffmpeg.org/releases/ffmpeg-0.11.1.tar.gz
tar -zxvf ffmpeg-0.11.1.tar.gz
cd ffmpeg-0.11.1
./configure --enable-libmp3lame --enable-libxvid --enable-libvorbis --enable-libgsm \
--enable-libfaac --enable-gpl --enable-nonfree
make
make install

sleep 5 && clear
echo "Downloading and installing JODConverter......................................................"
echo
sleep 1
cd /usr/adm
wget -c http://jodconverter.googlecode.com/files/jodconverter-core-3.0-beta-4-dist.zip
unzip jodconverter-core-3.0-beta-4-dist.zip

sleep 5 && clear
echo "Installing ApacheAnt......................................................................."
echo
sleep 1
cd /usr/adm
wget -c http://www.trieuvan.com/apache//ant/binaries/apache-ant-1.9.1-bin.tar.gz
tar -zxvf apache-ant-1.9.1-bin.tar.gz

sleep 5 && clear
echo "Checking out OM2.1........................................................................."
echo
sleep 1
cd /usr/adm
svn checkout http://svn.apache.org/repos/asf/openmeetings/branches/2.1/
cd /usr/adm/2.1

sleep 5 && clear
echo "Compiling and Installing OM 2.1............................................................"
echo
sleep 1
/usr/adm/apache-ant-1.9.1/bin/ant clean.all
/usr/adm/apache-ant-1.9.1/bin/ant -Ddb=mysql

cd /usr/adm/2.1/dist
mv red5/ /usr/lib/
cp -R /usr/adm/jodconverter-core-3.0-beta-4 /usr/lib/red5/webapps/openmeetings

sleep 5 && clear
echo "Setting up permissions and creating start-up scripts......................................."
echo
sleep 1
chown -R nobody /usr/lib/red5
chmod +x /usr/lib/red5/red5.sh
chmod +x /usr/lib/red5/red5-debug.sh

rm -f /etc/init.d/red5
touch /etc/init.d/red5
echo '#! /bin/sh
### BEGIN INIT INFO
# Provides: red5
# Required-Start: $remote_fs $syslog
# Required-Stop: $remote_fs $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Starts red5 server for Openmeetings.
### END INIT INFO
# For RedHat and cousins:
# chkconfig: 2345 85 85
# description: Red5 flash streaming server for OpenMeetings
# processname: red5
# Created By: Sohail Riaz (sohaileo@gmail.com)
# Modified by Alvaro Bustos
PROG=red5
RED5_HOME=/usr/lib/red5
DAEMON=$RED5_HOME/$PROG.sh
PIDFILE=/var/run/$PROG.pid
[ -r /etc/sysconfig/red5 ] && . /etc/sysconfig/red5
RETVAL=0
case "$1" in
start)
cd $RED5_HOME
start-stop-daemon --start -c nobody --pidfile $PIDFILE \
--chdir $RED5_HOME --background --make-pidfile \
--exec $DAEMON >/dev/null 2>/dev/null &
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
echo $! > $PIDFILE
fi
echo
;;
stop)
start-stop-daemon --stop --quiet --pidfile $PIDFILE \
--name java
rm -f $PIDFILE
echo
[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/$PROG
;;
restart|force-reload)
$0 stop
$0 start
;;
status)
# Debian and Ubuntu 10 status check
ps aux | grep -f $PIDFILE >/dev/null 2>/dev/null && RETVAL=0 || RETVAL=3
# Ubuntu 12 status check using improved "start-stop-daemon" status query
# (use the above command, or comment out above command and uncomment the two
below commands.
# start-stop-daemon --status --pidfile $PIDFILE
# RETVAL=$?
[ $RETVAL -eq 0 ] && echo "$PROG is running"
[ $RETVAL -eq 1 ] && echo "$PROG is not running and the pid file exists"
[ $RETVAL -eq 3 ] && echo "$PROG is not running"
[ $RETVAL -eq 4 ] && echo "$PROG - unable to determine status"
;;
checkports)
netstat -anp | grep soffice
netstat -anp | grep java
;;
*)
echo $"Usage: $0 {start|stop|restart|force-reload|status|checkports}"
RETVAL=1
esac
exit $RETVAL
' >> /etc/init.d/red5

chmod +x /etc/init.d/red5
update-rc.d red5 defaults

sleep 5 && clear
echo "Setting up Om to use MYSQL backend................................................"
echo
sleep 1
mv /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml \
/usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml-ori
mv /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/mysql_persistence.xml \
/usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i "s/Username=root/Username=$USERNAME/g" /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i "s/Password=/Password=$PASSWORD/g" /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i 's!<rtmpsslport>443</rtmpsslport>!<rtmpsslport>8443</rtmpsslport>!' /usr/lib/red5/webapps/openmeetings/config.xml
/etc/init.d/red5 start

sleep 5 && clear
echo "Openmeetings is now installed please open a browser to:"
echo "http://<OMServerIPaddress>:5080/openmeetings/install"
echo

echo "be sure and add these to firewall rules"
echo "#openmeetings"
echo "ACCEPT    net       fw             tcp          5080"
echo "ACCEPT    net       fw             tcp          1935"
echo "ACCEPT    net       fw             tcp          8088"

sleep 25
exit 0;;
;;


3) clear 
echo "Updating Openmeetings to latest Build...................................................."
echo
echo "Creating Working Directory.................................................................."
echo
sleep 1
if ! [ -d "/usr/adm" ]; then
mkdir /usr/adm;
fi
echo
echo "Stopping running OM Services..................................................................."
echo
sleep 1
/etc/init.d/red5 stop

echo
echo "Backing up current OM configuration............................................................"
echo
sleep 1
mv /usr/adm/backup_om.zip /usr/adm/backup_om.$(date -u +\%Y\%m\%d\%H\%M\%S).zip
cd /usr/lib/red5
./admin.sh -b -file /usr/adm/backup_om.zip

echo
echo "Dropping current Openmeetings Database........................................................."
echo
sleep 1
mysql -u root -p$PASSWORD -e "DROP DATABASE openmeetings;";

echo
echo "Creating DB and setting Permissions......................................................."
echo
sleep 1
mysql -u root -p$PASSWORD -e "CREATE DATABASE openmeetings DEFAULT CHARACTER SET 'utf8';";
mysql -u root -p$PASSWORD -e "GRANT ALL PRIVILEGES ON openmeetings.* TO \"openmeetings\"@\"localhost\" IDENTIFIED BY \"$PASSWORD\" WITH GRANT OPTION;";

sleep 5 && clear
echo "Archiving old OM Instance......................................................."
echo
sleep 1
mv /usr/lib/red5 /usr/lib/red5.$(date -u +\%Y\%m\%d\%H\%M\%S)

echo "Checking out Latest Build......................................................."
echo
sleep 1
cd /usr/adm
rm -Rf /usr/adm/singlewebapp
svn checkout http://svn.apache.org/repos/asf/incubator/openmeetings/trunk/singlewebapp/

sleep 5 && clear
echo "Installing ApacheAnt............................................................"
echo
sleep 1
cd /usr/adm
wget -c http://www.trieuvan.com/apache//ant/binaries/apache-ant-1.9.1-bin.tar.gz
tar -zxvf apache-ant-1.9.1-bin.tar.gz

sleep 5 && clear
echo "Compiling and Installing latest OpenMeetings Build.............................."
echo
sleep 1
cd /usr/adm/singlewebapp
/usr/adm/apache-ant-1.9.1/bin/ant clean.all
/usr/adm/apache-ant-1.9.1/bin/ant -Ddb=mysql

mv /usr/adm/singlewebapp/dist/red5/ /usr/lib/
cp -R /usr/adm/jodconverter-core-3.0-beta-4 /usr/lib/red5/webapps/openmeetings

sleep 5 && clear
echo "Setting permissions on OM Files................................................."
echo
sleep 1
chown -R nobody /usr/lib/red5
chmod +x /usr/lib/red5/red5.sh
chmod +x /usr/lib/red5/red5-debug.sh

echo "Setting up Om to use MYSQL backend.............................................."
echo
sleep 1
mv /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml \
/usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml-ori
mv /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/mysql_persistence.xml \
/usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i "s/Username=root/Username=$USERNAME/g" /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml
sed -i "s/Password=/Password=$PASSWORD/g" /usr/lib/red5/webapps/openmeetings/WEB-INF/classes/META-INF/persistence.xml

echo "Restoring OM Configuration....................................................."
echo
sleep 1
cd /usr/lib/red5
./admin.sh -i -file /usr/adm/backup_om.zip
sleep 5

echo "starting OM...................................................................."
echo
/etc/init.d/red5 start
sleep 10

sleep 5 && clear
echo "OpenMeetings has now been updated.............................................."
sleep 5

;;
4) exit 0;;
*) echo "Oopps!!! Please select choice 1, 2, 3 or 4";
echo "Press Enter to continue. . ." ; read ;;
esac
done
