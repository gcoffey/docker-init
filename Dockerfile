FROM mhart/alpine-node

MAINTAINER gareth@cachesure.co.uk

# Copy a directory into the image
COPY ./server /src

# Copy our container entry point script
COPY init.sh /init.sh

# Install some pre-reqs
RUN apk add --no-cache make gcc g++ python
 
ENTRYPOINT ["/init.sh"]
