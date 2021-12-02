import odoorpc
import os, sys

host = os.getenv("ODOO_HOST", "localhost")
port = int(os.getenv("ODOO_PORT", "8069"))
odoo = odoorpc.ODOO(host, port=port)

db = os.getenv("ODOO_DB", "odoo")
user = os.getenv("BACKUP_USER", "odoo")
#pw = os.getenv("BACKUP_USER_PW")
with open(os.getenv("BACKUP_USER_PW_FILE")) as file:
    pw = file.readline().strip()

odoo.login(db, user, pw)

channel_id = os.getenv("CHANNEL_ID", 1)
messages = odoo.env["mail.message"]
messages.create({"body": sys.argv[1], "channel_ids" : [channel_id]})
