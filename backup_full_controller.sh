#!/bin/bash

# Este script ejecuta el backup de todos los directorios origen que se ha solicitado
rm /backup_dir/root_bkp_*
rm /backup_dir/etc_bkp_*
rm /backup_dir/opt_bkp_*
rm /backup_dir/www_dir_bkp_*
#rm /backup_dir/proc_bkp_*
rm /backup_dir/var_bkp_*
rm /backup_dir/log_bkp_*

bash /opt/scripts/backup_full.sh /root /backup_dir

bash /opt/scripts/backup_full.sh /etc /backup_dir

bash /opt/scripts/backup_full.sh /opt /backup_dir

bash /opt/scripts/backup_full.sh /www_dir /backup_dir

# Este directorio se saltea ya que alli hay archivos de la que el usuario tiene denegado el permiso para abrirlo

#bash /opt/scripts/backup_full.sh /proc /backup_dir

bash /opt/scripts/backup_full.sh /var /backup_dir

bash /opt/scripts/backup_full.sh /var/log /backup_dir

ls -alh /backup_dir/*_bkp_*
