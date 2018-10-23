# Get-SvnRevision

Utilidad para descargar archivos desde un repositorio Subversion.

## Archivo de configuración

Es posible establecer valores de configuración creando un archivo llamado **Get-SvnRevision.conf** en la misma ruta en la cual se encuentra el archivo ejecutable. Las posibles opciones de configuración son las siguientes:

* http_user
* http_group
* exlude_files
* exclude_folders

Para facilitar la configuración de este archivo se adjunta una plantilla con las posibles variables así como configuraciones de ejemplo.

### http_user

Establece el nombre del usuario asociado al servicio **httpd**. En caso de no especificar ninguno, se intentará detectar utilizando el comando *httpd -V* y, en caso de no extraer la información necesaria, se establece a **apache**.

### http_group

Establece el nombre del grupo asociado al servicio **httpd**. En caso de no especificar ninguno, se intentará detectar utilizando el comando *httpd -V* y, en caso de no extraer la información necesaria, se establece a **apache**.

## exclude_files

Enumera una lista de los archivos que se eliminarán a la hora de desplegar el contenido descargado de Subversión en su ubicación final.

## exclude_folders

Enumera una lista de los directorios que se eliminarán a la hora de desplegar el contenido descargado de Subversión en su ubicación final.
