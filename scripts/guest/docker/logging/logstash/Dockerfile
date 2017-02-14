FROM logstash:5.2.0

# We use this filter to check the parsed message
RUN logstash-plugin install logstash-filter-multiline

ENV LS_HEAP_SIZE 128m

# Ensure it's our config that's loaded
CMD logstash -f /config-dir/logstash.conf