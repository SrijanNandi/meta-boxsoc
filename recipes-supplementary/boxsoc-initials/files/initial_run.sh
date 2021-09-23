FILE=`sudo find /etc -name "initial"`
if [[ $FILE == "/etc/initial" ]] ; then
	:
else
        sudo sh /etc/rc.initial.config
        sudo touch /etc/initial
fi
