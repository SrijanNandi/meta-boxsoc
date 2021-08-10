#!/bin/sh

logger "Starting basic configuration"

## Suricata configuration changes.

SURICATA_CONF_FILE="/etc/suricata/suricata.yaml"
INT_NAME=`ip link | awk -F: '$0 !~ "lo|vir|wl|sit|^[^0-9]"{print $2;getline}' | sort | uniq -D -w3`
INT_NAME_COUNT=`ip link | awk -F: '$0 !~ "lo|vir|wl|sit|^[^0-9]"{print $2;getline}' | sort | uniq -D -w3 | wc -l`
PROC_COUNT=`/usr/bin/nproc --all`

declare -a array=($(echo "$INT_NAME" | tr ' ' '\n'))

ITER=1
THREADS_COUNT=$(($PROC_COUNT-1))
if [ "$INT_NAME_COUNT" -le "1" ] || [ "$THREADS" -le "1" ]; then
   TMP_FILE="/tmp/suricata.temp"
   cat << 'EOF' > $TMP_FILE
  #- interface: FIRST_INT
  #  threads: THREADS_COUNT
  #  cluster-id: FIRST_ID
  #  defrag: no
  #  cluster-type: cluster_flow
  #  xdp-mode: driver
  #  xdp-filter-file:  /etc/suricata/ebpf/xdp_filter.bpf
  #  bypass: yes
  #  copy-mode: ips
  #  use-mmap: yes
  #  ring-size: 500000
  #  buffer-size: 5368709120
  #  rollover: no
  #  use-emergency-flush: yes
  #  copy-iface: SECOND_INT
  #- interface: SECOND_INT
  #  threads: THREADS_COUNT
  #  cluster-id: SECOND_ID
  #  defrag: no
  #  cluster-type: cluster_flow
  #  xdp-mode: driver
  #  xdp-filter-file:  /etc/suricata/ebpf/xdp_filter.bpf
  #  bypass: yes
  #  copy-mode: ips
  #  use-mmap: yes
  #  ring-size: 500000
  #  buffer-size: 5368709120
  #  rollover: no
  #  use-emergency-flush: yes
  #  copy-iface: FIRST_INT
EOF
else	
for ((i=0; i<${#array[@]}-1; i+=2)); do
   TMP_FILE="/tmp/suricata.temp$i"
   cat << 'EOF' > $TMP_FILE
  - interface: FIRST_INT
    threads: THREADS_COUNT
    cluster-id: FIRST_ID
    defrag: no
    cluster-type: cluster_flow
    #xdp-mode: driver
    #xdp-filter-file:  /etc/suricata/ebpf/xdp_filter.bpf
    bypass: yes
    copy-mode: tap
    use-mmap: yes
    #ring-size: 500000
    #buffer-size: 5368709120
    rollover: no
    use-emergency-flush: yes
    copy-iface: SECOND_INT
  - interface: SECOND_INT
    threads: THREADS_COUNT
    cluster-id: SECOND_ID
    defrag: no
    cluster-type: cluster_flow
    #xdp-mode: driver
    #xdp-filter-file:  /etc/suricata/ebpf/xdp_filter.bpf
    bypass: yes
    copy-mode: tap
    use-mmap: yes
    #ring-size: 500000
    #buffer-size: 5368709120
    rollover: no
    use-emergency-flush: yes
    copy-iface: FIRST_INT
EOF
   sed -i "s/- interface: FIRST_INT/- interface: ${array[$i]}/g" $TMP_FILE
   sed -i "s/cluster-id: FIRST_ID/cluster-id: $(expr 99 - $ITER)/g" $TMP_FILE
   sed -i "s/copy-iface: SECOND_INT/copy-iface: "${array[$i+1]}"/g" $TMP_FILE
   sed -i "s/- interface: SECOND_INT/- interface: "${array[$i+1]}"/g" $TMP_FILE
   sed -i "s/cluster-id: SECOND_ID/cluster-id: $(expr 99 - $ITER - 1)/g" $TMP_FILE
   sed -i "s/copy-iface: FIRST_INT/copy-iface: "${array[$i]}"/g" $TMP_FILE 
   sed -i "s/threads: THREADS_COUNT/threads: $THREADS_COUNT/g" $TMP_FILE
   ITER=$(expr $ITER + 2)

done
fi

cat /tmp/suricata.temp* >> /tmp/newfile.temp

if [ -f $SURICATA_CONF_FILE ]; then
   cp -r /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.ORIG
fi

sed -i "/AF_PACKET/ e cat /tmp/newfile.temp" $SURICATA_CONF_FILE
sed -i '/AF_PACKET/d' $SURICATA_CONF_FILE
rm -rf /tmp/suricata.temp*
rm -rf /tmp/newfile.temp*

## Graylog configuration changes

GRAYLOG_CONF="/etc/graylog/server/server.conf"
SEC_PWD=`/usr/bin/ranpwd --alphanum --lower 96`
ROOT_PWD=`/bin/echo -n "boxsoc" | /usr/bin/tr -d '\n' | /usr/bin/sha256sum | /usr/bin/cut -d" " -f1`

if [ -f ${GRAYLOG_CONF} ]; then
	cp -r ${GRAYLOG_CONF} ${GRAYLOG_CONF}.ORIG
fi

sed -i "s/password_secret =/password_secret = ${SEC_PWD}/g" ${GRAYLOG_CONF}
sed -i "s/root_password_sha2 =/root_password_sha2 = ${ROOT_PWD}/g" ${GRAYLOG_CONF}

logger "Configuration done"

## Initial Selection

echo -n ""

###########################################

INT_NAME=`/sbin/ip link | /usr/bin/awk -F: '$0 !~ "lo|vir|wl|sit|^[^0-9]"{print $2;getline}' | /usr/bin/awk '{ sub(/^[ \t]+/, ""); print }' | /usr/bin/sort`

declare -a array=($(echo "$INT_NAME"))

function interface_spec() {
	for ((i=0; i<${#array[@]}; i+=1)); do
		echo -e -n "$(($i + 1))"; echo -e -n ") "
		MAC_ADDR=`/bin/cat /sys/class/net/${array[$i]}/address`
		STATE=`/bin/cat /sys/class/net/${array[$i]}/operstate`
		CARRIER=`/bin/cat /sys/class/net/${array[$i]}/carrier`
	            if [ "$CARRIER" -eq "0" ]; then
		        CARRIER_STATE="physical link is down"
	            else
		        CARRIER_STATE="physical link is up"
	            fi
		echo -e "${array[$i]}\t\t\t$CARRIER_STATE\t$MAC_ADDR"
	done
}

function wan_interface_file() {
	echo -e "1) Static"
	echo -e "2) Dynamic (DHCP)"
	echo -e "3) None"
	echo
	read -p "Enter the number for the configuration type on WAN: " CONF_TYPE
	case $CONF_TYPE in
		[1]* )
			read -p "Enter the WAN IP Address with subnet mask: " WAN_IP
			read -p "Enter the Default Gateway: " WAN_GATEWAY
			read -p "Enter a DNS Address: " WAN_DNS
			cat << 'EOF' > /tmp/${array[$i]}.network
[Match]
Name=INTERFACE_NAME
KernelCommandLine=!nfsroot
[Network]
INTERFACE_ADDRESS
INTERFACE_GATEWAY
INTERFACE_DNS
EOF
			sed -i "s/INTERFACE_NAME/${array[$i]}/g" "/tmp/${array[$i]}.network"
			sed -i "s~INTERFACE_ADDRESS~Address=$WAN_IP~g" "/tmp/${array[$i]}.network"
			sed -i "s/INTERFACE_GATEWAY/Gateway=$WAN_GATEWAY/g" "/tmp/${array[$i]}.network"
			sed -i "s/INTERFACE_DNS/DNS=$WAN_DNS/g" "/tmp/${array[$i]}.network"
			;;
		[2]* )
			cat << 'EOF' > /tmp/${array[$i]}.network
[Match]
Nane=INTERFACE_NAME
KernelCommandLine=!nfsroot
[Network]
INTERFACE_ADDRESS
[DHCPv4]
UseHostname=false
EOF
			sed -i "s/INTERFACE_NAME/${array[$i]}/g" "/tmp/${array[$i]}.network"
			sed -i "s/INTERFACE_ADDRESS/DHCP=v4/g" "/tmp/${array[$i]}.network"
			;;
		[3]* )

			cat << 'EOF' > /tmp/${array[$i]}.network
[Match]
Nane=INTERFACE_NAME
KernelCommandLine=!nfsroot
[Network]
INTERFACE_ADDRESS
EOF
			sed -i "s/INTERFACE_NAME/${array[$i]}/g" "/tmp/${array[$i]}.network"
			sed -i "s/INTERFACE_ADDRESS/Address=0.0.0.0/g" "/tmp/${array[$i]}.network"
			;;
		* )
			echo -e "Please select a valid configuration."
			;;
	esac
}

function lan_interface_file() {
	read -p "Enter the LAN IP Address with subnet mask: " LAN_IP
	cat << 'EOF' > /tmp/${array[$i]}.network
[Match]
Name=INTERFACE_NAME
KernelCommandLine=!nfsroot
[Network]
INTERFACE_ADDRESS
EOF

sed -i "s/INTERFACE_NAME/${array[$i]}/g" "/tmp/${array[$i]}.network"
sed -i "s/INTERFACE_ADDRESS/Address=$LAN_IP/g" "/tmp/${array[$i]}.network"
}




if [ -f "/tmp/*.network" ]; then
	rm -rf /tmp/*.network
fi

echo
interface_spec
echo
read -p "Enter the number of the interface you wish to configure " NUM
echo
for ((i=0; i<=${#array[@]}; i+=1)); do
    case $NUM in
        [$(($i+1))]* ) read -p "Do you want to configure it as WAN or LAN: " CHOICE
		       if [[ $CHOICE == "WAN" || $CHOICE == "wan" ]]; then
		           sudo /bin/rm -rf /etc/systemd/network/en.network
			   wan_interface_file
			   sudo /bin/cp /tmp/${array[$i]}.network /etc/systemd/network
			   sudo /bin/systemctl restart systemd-networkd
			   WANS_IP=`/sbin/ip -o -4 addr list ${array[$i]} | /usr/bin/awk '{print $4}' | /usr/bin/cut -d/ -f1`
		       elif [[ $CHOICE == "LAN" || $CHOICE == "lan" ]]; then
			   sudo /bin/rm -rf /etc/systemd/network/en.network
		           lan_interface_file
			   sudo /bin/cp /tmp/${array[$i]}.network /etc/systemd/network
			   sudo /bin/systemctl restart systemd-networkd
		       else
		           echo ""
		       fi
		       break
	  	       ;;
		* )
		       echo "Invalid Entry "
		       exit 1
		       ;;
    esac
done

function remove_elasticsearch {
	sudo systemctl stop elasticsearch
	sudo sleep 2
	sudo apt-get remove --purge elasticsearch*
}

function remove_siem {
	sudo systemctl stop graylog-server
	sudo sleep 2
	sudo apt-get remove --purge graylog*
}

function graylog_for_public {
	sed -i "s/server_name 0.0.0.0;/server_name $1;/g" /etc/nginx/sites-available/boxsoc_server
}

function elasticsearch_for_public {
	sed -i "s/#network.host:[[:space:]]192.168.0.1/network.host: $1/g" /etc/elasticsearch/elasticsearch.yml
}


echo -e " Select the type of Installation: "
echo
echo -e " 1) Log Forwarder "
echo -e " 2) Only SIEM GUI "
echo -e " 3) Only Elasticsearch DB "
echo -e " 4) Both SIEM GUI along with Elasticsearch DB "
echo
read -p "Enter the Installation Mode: " im

case $im in
	[1]* )

		;;
	[2]* )
		remove_elasticsearch
		;;
	[3]* )
		#remove_siem
                elasticsearch_for_public $WANS_IP
		;;
	[4]* )
		graylog_for_public $WANS_IP
		;;
	* )
		echo "Invalid Option. Selct from option 1 to 4."
		;;
esac

############################################

## Job done, remove it from systemd services
systemctl disable initscript.service


## Disable swap if swap memory allocated is 0 (zero)

swap_size=`sudo swapon -s | tail -n 1 | awk '{ print $3 }'`

if [ $swap_size -eq 0 ]; then
	sudo swapoff --all
	sudo sed -e '/swap/ s/^#*/#/' -i /etc/fstab
        sudo shutdown -r now
fi
