#!/bin/sh

if [ -e /var/run/.initial_script_run ] ; then
	:
else
	sudo sh /etc/rc.initial.config
	sudo touch /var/run/.initial_script_run
fi
