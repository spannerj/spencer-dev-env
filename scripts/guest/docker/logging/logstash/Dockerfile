FROM logstash:5.1.2

# We use this filter to check the parsed message
RUN logstash-plugin install logstash-filter-multiline

# Ensure it's our config that's loaded
CMD logstash -f /config-dir/logstash.conf
