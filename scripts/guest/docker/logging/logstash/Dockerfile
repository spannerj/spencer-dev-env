FROM logstash:5.2.0-alpine

# We use this filter to check the parsed message
RUN logstash-plugin install logstash-filter-multiline

# Change initial heap
RUN sed -i -e 's/.*Xms256m.*//' /usr/share/logstash/config/jvm.options && \
 echo "-Xms128m" >> /usr/share/logstash/config/jvm.options

# Ensure it's our config that's loaded
CMD logstash -f /config-dir/logstash.conf