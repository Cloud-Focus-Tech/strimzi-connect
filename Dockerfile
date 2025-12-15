#---------------------------------------------------------------
# ---- Builder stage: download artifacts ----
#---------------------------------------------------------------
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.4 AS builder
# Install curl, tar, gzip
RUN microdnf install -y tar gzip unzip && microdnf clean all
ARG DEBEZIUM_VER=3.3.1.Final

WORKDIR /tmp

# Copy the local ZIP into the image (adjust path/name if needed)
COPY plugins/confluentinc-connect-transforms-1.6.2.zip /tmp/ct.zip
COPY plugins/confluentinc-kafka-connect-avro-converter-8.1.0.zip /tmp/cfavro.zip
COPY plugins/debezium-connector-oracle-3.3.1.Final-plugin.zip /tmp/debezium-oracle.zip


RUN mkdir -p /tmp/plugins/debezium-oracle && \
    unzip -q /tmp/debezium-oracle.zip -d /tmp/plugins/debezium-oracle && \
    rm -f /tmp/plugins/debezium-oracle/debezium-connector-oracle/ojdbc*.jar 

COPY plugins/ojdbc11-23.9.0.25.07.jar /tmp/plugins/debezium-oracle/debezium-connector-oracle/ojdbc11-23.9.0.25.07.jar

RUN mkdir -p /tmp/plugins/confluent-transforms && \
    unzip -q /tmp/ct.zip -d /tmp/plugins/confluent-transforms 

RUN mkdir -p /tmp/plugins/confluentinc-kafka-connect-avro-converter && \
    unzip -q /tmp/cfavro.zip -d /tmp/plugins/confluentinc-kafka-connect-avro-converter 



#---------------------------------------------------------------
# OUTPUT stage: copy plugins and download any artifacts     ----
# Match your operator: Strimzi 0.46 → Kafka 4.0 base
#---------------------------------------------------------------

FROM quay.io/strimzi/kafka:0.46.0-kafka-4.0.0

# Strimzi runs as uid 1001
USER root
# Copy the plugins from the builder stage
COPY --from=builder /tmp/plugins /opt/kafka/plugins

# Unzip the Avro Converter plugin
RUN  chown -R 1001:0 /opt/kafka/plugins 

# Switch back to the non-root user
USER 1001
