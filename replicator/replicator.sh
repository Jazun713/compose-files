#! /bin/bash

# Repeat every second
while true; do
  sleep "$waitTime"

  # Find Mongo Instances
  mongoInstances=$(dig +short "$mongoHostname")

  # If Instances is empty, skip loop instead of erroring
  if [ "$mongoInstances" == "" ]; then
    printf %s\\n "No Mongo instances found"
    continue
  fi

  # Find Primary Instance
  mongoPrimary=""
  for instance in $mongoInstances; do
    isPrimary=$(mongo --quiet --host "$instance" --eval "rs.isMaster().ismaster")
    if [ "$isPrimary" = "true" ]; then
      mongoPrimary="$instance"
    fi
  done

  # If no primary found, make one
  if [ "$mongoPrimary" = "" ]; then
    printf %s\\n "No replication set found, creating one:"

    # Try to elect primary, check if it worked.
    for instance in $mongoInstances; do
      if [ "$mongoPrimary" == "" ]; then
        # Try to elect
        mongo --quiet --host "$instance" --eval "rs.initiate()" 1> /dev/null

        # Check if primary
        if [ "$(mongo --quiet --host "$instance" --eval "rs.isMaster().ismaster")" ]; then
          mongoPrimary=$(echo "$mongoInstances" | awk '{print $1}')
        fi
      fi
    done

    printf %s\\n "Primary instance created: $mongoPrimary"

  fi

  # Find all Replicated Mongo Instances
  replicatedMongoInstances=""
  numberOfReplicatedInstances=$(mongo --quiet --host "$mongoPrimary" --eval "rs.status().members.length")

  for i in $(seq 1 "$numberOfReplicatedInstances"); do
    instance=$(mongo --quiet --host "$mongoPrimary" --eval "rs.status().members[$i].name" | awk -F: '{printf $1}')
    replicatedMongoInstances="$replicatedMongoInstances $instance"
  done

  # Compare list of mongo instances to mongo secondaries
  for instance in $mongoInstances; do
    # If it's not replicated then add it to replication set
    if [ "$mongoPrimary" != "$instance" ] && [[ "$replicatedMongoInstances" != *"$instance"* ]]; then 
      mongo --quiet --host "$mongoPrimary" --eval "rs.add(\"$instance\")" 1> /dev/null
      printf %s\\n "Secondary instance added: $instance"
    fi
  done

done
