FROM mongo
MAINTAINER joshua.campbell3@extendhealth.com
RUN apt-get update && apt-get install dnsutils -y
COPY ./replicator.sh /bin/replicator.sh
ENTRYPOINT /bin/replicator.sh

