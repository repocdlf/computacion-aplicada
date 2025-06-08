#!/bin/bash

# Verificar si como argumento se pasa la palabra “help”
if [[ "help" == $1 ]]; then
  echo "Valores que acepta el script como origen: (son los directirios de la maquina que se van a backupear)"
  echo "/root"
  echo "/etc"
  echo "/opt"
  echo "/proc"
  echo "/www_dir"
  echo "/backup_dir"
  echo "Todos ellos comprimidos individualmente en formato .tar.gz"
  echo "/var"
  echo "Este ultimo se particiona en partes pequeñas para que pueda se subido"
  echo "El script valida que los sistemas de archivo origen y destino esten disponibles antes de ejecutar el backup"
  echo "Para volver a abrir la ayuda ejecute el script con la opcion -help"
  echo "El script acepta dos argumentos para hacer el backup. El primer argumento como origen y el segundo argumento como destino"
  echo "Valores que acepta el script como destino: (es el directorio de la maquina en donde se va a backupear)"
  echo "/backup_dir"
  echo "Repositorio de git en la que se van a subir los archivos:"
  echo "https://"
  exit 0

# Valida si hay dos argumentos.
elif [ $# -ne 2 ]; then
  echo "Parametros incorrectos. El script acepta dos argumentos para hacer el backup; directorio origen y directorio destino. Para mas detalle relanzar el script con la opcion help"
  exit 1
fi

# Validar que directorios de origen y destino estén disponibles
if [ ! -d "$1" ]; then
  echo "El directorio origen indicado ($1) no existe"
  exit 1
elif [ ! -d "$2" ]; then
  echo "El directorio destino indicado ($2) no existe"
  exit 1
fi

# Validar que el directorio destino sea /backup_dir
if [[ $(basename "$2") != "backup_dir" ]]; then
  echo "Los backups generados deben almacenarse en la partición que tiene montado el directorio /backup_dir"
  exit 1
fi

# Fecha en formato ANSI (YYYYMMDD)
# %Y año
# %m mes
# %d dia
FECHA=$(date +%Y%m%d)

# Nombre del archivo de backup: se concatena el directorio mas una cadena fija mas la fecha como nombre del archivo backup
# basename: comando que extrae el nombre eliminando los directorios que lo preceden
# $1 el directorio origen que se va a backupear
BACKUP=$(basename "$1")_bkp_$FECHA.tar.gz

# Crear el backup
# tar es un programa utilitario para manipular archivos, en este caso lo vamos a usar para comprimir directorios
# -c opcion que indica que debe crearse un nuevo archivo
# -z opcion que indica se va a usar el compresor gzip
# -f opcion que indica el nombre del archivo tar
# $1 el directorio origen que se va a backupear
# $2 directorio destino donde se va a backupear
# -C opcion que indica que debe cambiar al directorio origen antes de comprimir
# . directorio actual en la que se ubico el proceso
echo "Origen: $1"
echo "Destino: $2/$BACKUP"

tar -czf "$2/$BACKUP" -C "$1" .

echo "Nombre del archivo backup: $BACKUP"
echo "Fecha del backup en formato ANSI: $FECHA"

# Verificar si el backup se creó correctamente
if [ -e "$2/$BACKUP" ]; then
  echo "El backup se creo correctamente"
else
  echo "El backup finalizo con error"
  exit 1
fi

# Hacemos un particionamiento al backup de /var para que pueda ser subido al repositorio
# En partes de 10 megabytes
if [[ $(basename "$1") == "var" ]]; then
  echo "Particionamiento del backup de /var"
  split -b 10M "$2/$BACKUP" "$2/$BACKUP"_parte_
  # Eliminamos el archivo grande para que pueda se subido a git
  rm "$2/$BACKUP"
  # Descomentar la siguiente linea para reconstruir las partes del archivo comprimido
  #cat "$2/$BACKUP"_parte_* > "$2/$BACKUP"
  exit 0
fi
