Install oracle instant_client_11_2

unzip it and save it at the location: /opt/oracle

execute the command:   nano ~/.profile

add the below lines there and save it:

export DYLD_LIBRARY_PATH="/opt/oracle/instantclient_11_2"

export ORACLE_HOME="/opt/oracle/instantclient_11_2"


In case of issues...


http://osxdaily.com/2015/10/05/disable-rootless-system-integrity-protection-mac-os-x/
