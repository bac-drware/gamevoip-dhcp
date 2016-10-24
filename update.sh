#!/bin/bash

dhcp_new=/opt/dhcp/backups/dhcp_edit_new.txt
dhcp_old=/tmp/dhcp_edit_old.txt
dhcp_diff=/tmp/dhcp_edit_diff.txt
dhcp_msg=/tmp/dhcp_edit_msg.txt
dhcp_status=/tmp/dhcp_edit_status.txt

#backup config
cp /opt/dhcp/dhcpd.conf /opt/dhcp/backups/dhcpd.conf.`date +%d%m%Y-%H%M`

#edit config
mv $dhcp_new $dhcp_old
clear
echo ""
echo "Starting Editor"
sleep 1
echo "You may now edit dhcpd.conf - Use Caution!!!"
sleep 3
/usr/bin/vim /opt/dhcp/dhcpd.conf
cat /opt/dhcp/dhcpd.conf > $dhcp_new

#create pushover message
diff $dhcp_new $dhcp_old > $dhcp_diff
echo "GAMEVOIP_DHCP changes:" > $dhcp_msg
echo "" >> $dhcp_msg
cat $dhcp_diff >> $dhcp_msg

#restart dhcpd
clear
echo ""
if [[ -s $dhcp_diff ]] ; then
#github
echo "Pushing changes to Git"
/usr/bin/git commit -am 'Changes via update.sh'
/usr/bin/git push original master
echo ""
echo "Restarting DHCP Server - About 10 second wait"
/usr/sbin/service isc-dhcp-server restart
sleep 5
/usr/sbin/service isc-dhcp-server status
/usr/sbin/service isc-dhcp-server status > $dhcp_status
else
echo "No changes to dhcpd.conf detected"
echo ""
fi

echo ""
if [[ -s $dhcp_diff ]] ; then
echo "Changes were saved to dhcpd.conf"
echo "Pushover message sent"
#exit
curl -s \
  --form-string "`cat /home/drware/pushover/pushover_drw_cred`" \
  --form-string "`cat /home/drware/pushover/pushover_script`" \
  --form-string "message=`cat $dhcp_msg`" \
  https://api.pushover.net/1/messages.json
echo "Done"
echo ""
else
echo ""
fi ;

exit
