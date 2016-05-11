FROM postgres
# add backup scripts
ADD ./docker/postgres/backup.sh /usr/local/bin/backup  
ADD ./docker/postgres/restore.sh /usr/local/bin/restore  
ADD ./docker/postgres/list-backups.sh /usr/local/bin/list-backups  
ADD ./docker/postgres/shell.sh /usr/local/bin/shell

# make them executable
RUN chmod +x /usr/local/bin/restore  
RUN chmod +x /usr/local/bin/list-backups  
RUN chmod +x /usr/local/bin/backup  
RUN chmod +x /usr/local/bin/shell  

# add init script
ADD ./docker/postgres/init.sh /docker-entrypoint-initdb.d/
