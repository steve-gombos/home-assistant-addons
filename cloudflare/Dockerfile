ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ARG DEHYDRATED_VERSION
RUN apk add --no-cache openssl \
  && curl -s -o /usr/bin/dehydrated \
    "https://raw.githubusercontent.com/lukas2511/dehydrated/v${DEHYDRATED_VERSION}/dehydrated" \
  && chmod a+x /usr/bin/dehydrated

# Copy data for add-on
COPY *.sh /
RUN chmod a+x /*.sh

CMD [ "/run.sh" ]
