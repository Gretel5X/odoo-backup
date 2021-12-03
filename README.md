# odoo-backup
A simple app to backup odoo and post notifications to a channel.

You have to build and tag the image yourself. Everything is designed to work with [docker swarm](https://docs.docker.com/engine/swarm/) and using compose files.
A sample service definition could be:
```yaml
version: '3.8'
services:
  backup:
    image: backup:latest        # your registry or locally build
    deploy:
      replicas: 1
      placement:
        constraints:
          - "node.role==worker" # this is arbitrary
    environment:
      - ODOO_HOST=myodoo.org
      - ODOO_DB=odoo
      - ODOO_PORT=8069
      - BACKUP_USER=backups@myodoo.org
      - BACKUP_USER_PW_FILE=/run/secrets/backup-user-pw
      - MASTER_DB_PW_FILE=/run/secrets/db-master
      - BACKUP_DIR=/mnt/backups
      - CHANNEL_ID=1
      - PYTHONUNBUFFERED=1      # pass this to get logs from python
    volumes:
      - ./backup.sh:/home/backup.sh
      - ./notify_odoo.py:/home/notify_odoo.py
      - ./job:/etc/crontabs/root
      - odoo-backups:/mnt/backups
    secrets:
      - db-master
      - backup-user-pw

secrets:
  db-master:
    external: true
  backup-user-pw:
    external: true

volumes:
  odoo-backups:
    driver: local
    driver_opts:
      type: cifs
      device: //yoursambashare.local/backups/odoo
      o: addr=yoursambashare.local,username=*******,password=*******,file_mode=0777,dir_mode=0777
```
## Parameter

- `BACKUP_DIR`: The path where the file should be safed e.g. a NFS mounted to the container.
- `MASTER_DB_PW_FILE`: The path to a file containing the master password. This is designed to work with docker secrets.
- `ODOO_DB`: The name of the database to backup.
- `ODOO_HOST`: The host of the odoo instance. If deploying this alongside odoo in the same stack, use the service name. Otherwise it should be the loadbalancers ip or the hostname.
- `ODOO_PORT`: Default port for the odoo instance is 8069, but this has to be set anyway.
- `BACKUP_USER`: The email address to use for login. It makes sense to create a new dummy user called "Backup" or something with minimal access rights.
- `BACKUP_USER_PW_FILE`: The path to a file containing the users password. Again, this is designed to work with docker secrets.
- `CHANNEL_ID`: The id of the channel to post to. This channel should be created prior to first backup job run and the `BACKUP_USER` should be a member of it.


## Contribution

Feel free to open an issue :)
