FROM openjdk:8-jre-alpine3.9

# Add the archiva user and group with a specific UID/GUI to ensure
#RUN groupadd --gid 1000 archiva && useradd --gid 1000 -g archiva archiva
RUN addgroup -g 1080 archiva && adduser -u 1080 -D -G archiva archiva
RUN apk add --update curl bash && rm -rf /var/cache/apk

# Set archiva-base as the root directory we will symlink out of.
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk/jre
ENV ARCHIVA_HOME /archiva
ENV ARCHIVA_BASE /archiva-data

# Used to tell the resource-retreiver.sh script
# to build the most recent snapshot.
#
# Only specified in the v2-snapshot branch, and needed
# because we use docker cloud builds.
ENV BUILD_SNAPSHOT_RELEASE true

#
# Capture the external resources in two a layers.
# 
COPY resource-retriever.sh /tmp/resource-retriever.sh
RUN chmod +x /tmp/resource-retriever.sh &&\
  bash /tmp/resource-retriever.sh &&\
  rm /tmp/resource-retriever.sh

#
# Perform all setup actions
#
COPY files /tmp
RUN chmod a+x /tmp/setup.sh && bash /tmp/setup.sh && rm /tmp/setup.sh

# Standard web ports exposted
EXPOSE 8080/tcp

HEALTHCHECK CMD /healthcheck.sh

# Switch to the archiva user
USER archiva

# The volume for archiva
VOLUME /archiva-data

# Use SIGINT for stopping
STOPSIGNAL SIGINT

# Use our custom entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]
