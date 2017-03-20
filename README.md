# haproxy_rocketchat

## rc_backend:
haproxy + mongo.  Used if you have your backend and frontend servers on different hardware/VMs.

## rc_frontend:
haproxy. Reverse proxy for Rocket.Chat frontend.  Use in conjunction with Rocket.Chat container and rc_backend.

## rc_singlehost:
haproxy + mongo.  Haproxy config for mongo backend and Rocket.Chat containers on the same host.
