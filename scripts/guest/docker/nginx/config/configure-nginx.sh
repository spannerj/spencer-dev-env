echo "- - - Configuring Nginx - - -"
#configure nginx
cp -rf /share/server.conf /etc/nginx/conf.d/
rm -rf /etc/nginx/nginx.conf
rm -rf /etc/nginx/conf.d/default.conf
cp -rf /share/nginx.conf /etc/nginx
mkdir /var/nginx
mkdir /var/nginx/client_body_temp

echo "- - - Generating SSL Key - - -"
#ssl key configuration
country=GB
state=devon
locality=plymouth
organization=land_registry
organizationalunit=seaton_court
email=testsslkey@landregistry.gov.uk

#generate ssl key
mkdir /etc/ssl/keys
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/keys/ssl.key -out /etc/ssl/certs/ssl.crt -subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
