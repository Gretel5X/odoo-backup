#!/bin/sh

# vars
BACKUP_DIR=${BACKUP_DIR}
#ADMIN_PW=${MASTER_DB_PW}
ADMIN_PW=$(cat ${MASTER_DB_PW_FILE})

# create a backup
curl -X POST \
    -F "master_pwd=${ADMIN_PW}" \
    -F "name=${ODOO_DB}" \
    -F "backup_format=zip" \
    -o ${BACKUP_DIR}/${ODOO_DB}.$(date +%F).zip \
    http://${ODOO_HOST}:${ODOO_PORT}/web/database/backup


res=$?
# delete old backups
find ${BACKUP_DIR} -type f -mtime +7 -name "${ODOO_DB}.*.zip" -delete

# only post success if both commands were successful
if [ res = $? ]; then
    msg="Backup successful"
else
    msg="Backup failed, please check the logs!"
fi

python3 /home/notify_odoo.py $msg

echo "Backup done!"
