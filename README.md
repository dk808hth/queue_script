# queue_script
sudo wget https://raw.githubusercontent.com/dk808zelnode/queue_script/master/queue_pos.sh

Once script is installed enter `sudo nano queue_pos.sh` and enter the path to cli in front of zelcash-cli...on line 3. Line that needs to be edited should look like this `ZNLISTCMD="zelcash-cli listzelnodes |jq -r '[.[] |select(.tier=="BASIC") |{(.txhash):(.status+" "+(.version|tostring)+" "+.addr+" "+(.lastseen|tostring)+" "+(.activetime|tostring)+" "+(.lastpaid|tostring)+" "+.ipaddress)}]|add'"` So just add `/usr/bin/` or `/usr/local/bin/` in front of zelcash-cli. Example: `ZNLISTCMD="usr/bin/zelcash-cli listzelnodes |jq -r '[.[] |select(.tier=="BASIC")....
