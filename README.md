Install oracle instant_client_11_2 (basic, sqlplus and sdk. Merge all these folders into one instantclient_11_2)

unzip it and save it at the location: /opt/oracle

execute the command:   nano ~/.profile or nano ~/.bash_profile

add the below lines there and save it:

```
export DYLD_LIBRARY_PATH="/opt/oracle/instantclient_11_2"
export OCI_DIR="/opt/oracle/instantclient_11_2"
export ORACLE_HOME="/opt/oracle/instantclient_11_2"
```

Exit it and check on terminal
ENV

It should contain the above variables


To resolve this error(oci8.c:601:in oci8lib_250.bundle: ORA-24454: client host name is not set (OCIError)) run 
sudo /bin/bash -c "echo '127.0.1.1 ${HOSTNAME}' >> /etc/hosts"

In case of issues...


http://osxdaily.com/2015/10/05/disable-rootless-system-integrity-protection-mac-os-x/
