FROM lr_base_java:1

# We're changing the command to create a jar then run it to prevent gradle running in the background using hundreds of megs of ram.
# Any apps that use this as a base must import the shadowjar plugin into the build.gradle
CMD gradle shadowJar --no-daemon && java -jar $(find /src/build/libs -name '*.jar' | head -1)