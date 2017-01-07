#!/bin/sh 
#
# extra wrap fffr specific commands to get nice cronjob for backend-data
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
src=/home/freifunk/ffmap-backend

# from https://nilsschneider.net/2013/02/03/ffmap-tutorial.html
# modified but generally outdatet.. 
GWL=`batctl gwl -n`
SELF=`echo "$GWL" | head -n 1 | sed -r -e 's@^.*MainIF/MAC: [^/]+/([0-9a-f:]+).*$@\1@'`
GWS=`(echo "$GWL" | tail -n +2 | grep -v '^No' | sed 's/=>//' | awk '{ print $1 }') | while read a; do echo -n " $a "; done`
if [ `cat /sys/class/net/bat0/mesh/gw_mode` = server ]; then
    GWS="$GWS $SELF"
fi


/home/freifunk/ffnord-alfred-announce/announce.sh
sleep 5 
cd $src
# pkill backend.py -e
python3m $src/backend.py -p 60 -d $src/ffmap-data-new -a $src/aliases_sn.json $src/aliases_nodes.json --with-rrd --vpn $GWS 
# -a /home/freifunk/ffmap-backend/aliases.json --with-rrd 

# Graphics ..
# see magic graphic.sh file every ten minute do pictures
# actually done with seperate cronjob
# if [ $(echo - $(($(date +%M)%10))) = 0 ]; then $src/clientpic.sh; fi

# do some magic for gatewaylist in nodes.json
# for alpha in $GWS ; do
#      alphaclean=$(echo $alpha |sed s/":"//g)           # get mac without doppelpoints 
#      beta=$(echo -n \"gateway\"\:\ \"$alphaclean)	# make complete beta string in one step
#      sed -i s/"\"gateway\"\:\ \"$alpha"/"$beta"/g ffmap-data/nodes.json  # change all gateway to clean_mac = beta  
#	# echo "##"$alpha"##"
#	# echo "##"$alphaclean"##"
#done

# some magic with nodes.json and nodelist.json
# be sure to not mess it - eindeutige regex
# for adding geo better use aliases_nodes.json (while loosing dynamic info)
# for easy changing of existing names and geo
sed -i s/'fffr-0280R'/'Rasthaus Grether'/g $src/ffmap-data-new/nodes.json
sed -i s/'215-30b5c2c28644'/'Bertoldsbrunnen'/g $src/ffmap-data-new/nodes.json
sed -i s/'fffr-0272R'/'Kaiserstuhlstr. Refugee'/g $src/ffmap-data-new/nodes.json
sed -i s/'fffr-334-C'/'Kaiserstuhlstr. Refugee2 cpe'/g $src/ffmap-data-new/nodes.json
sed -i s/'freifunk-rdl'/'Radio Dreyeckland rdl.de'/g $src/ffmap-data-new/nodes.json
sed -i s/'freifunk-strandcafe'/'Strandcafe Grether'/g $src/ffmap-data-new/nodes.json
sed -i s/'freifunk-'/'fffr-'/g $src/ffmap-data-new/nodes.json
sed -i s/'FREIFUNK-'/'fffr-'/g $src/ffmap-data-new/nodes.json
sed -i s/'fffr-b0487adef32c-1337'/'Chaos Computer Club Fr cccfr.de'/g $src/ffmap-data-new/nodes.json
sed -i s/'fffr-375-CR'/'cccfr.de Dunantstr. uplink'/g $src/ffmap-data-new/nodes.json
sed -i s/'fffr-'/''/g $src/ffmap-data-new/nodes.json
sed -i s/'123-c46e1fe7d1b2'/'asta_123'/g $src/ffmap-data-new/nodes.json
sed -i s/'125-c46e1fe7f1ce'/'asta_125'/g $src/ffmap-data-new/nodes.json
sed -i s/'124-c46e1fe7ce6c'/'asta_124'/g $src/ffmap-data-new/nodes.json
sed -i s/'e8de27bbe958-57'/'Marienbad Theather 57'/g $src/ffmap-data-new/nodes.json
sed -i s/'e8de27bbe96c-53'/'Marienbad Theather 53'/g $src/ffmap-data-new/nodes.json

# finaly overwrite old data
cp $src/ffmap-data-new/* $src/ffmap-data -r

# make some fancy oldschool format for ffmap-d3
cd $src 
jq -n -f ffmap-d3.jq     --argfile nodes ffmap-data/nodes.json     --argfile graph ffmap-data/graph.json > ffmap-data/ffmap-d3.json
