# Get-SvnRevision

Utilidad para descargar archivos desde un repositorio Subversion.

## Archivo de configuraci�n

Es posible establecer valores de configuraci�n creando un archivo llamado **Get-SvnRevision.conf** en la misma ruta en la cual se encuentra el archivo ejecutable. Las posibles opciones de configuraci�n son las siguientes:

* http_user
* http_group
* exlude_files
* exclude_folders

Para facilitar la configuraci�n de este archivo se adjunta una plantilla con las posibles variables as� como configuraciones de ejemplo.

### http_user

Establece el nombre del usuario asociado al servicio **httpd**. En caso de no especificar ninguno, se intentar� detectar utilizando el comando *httpd -V* y, en caso de no extraer la informaci�n necesaria, se establece a **apache**.

### http_group

Establece el nombre del grupo asociado al servicio **httpd**. En caso de no especificar ninguno, se intentar� detectar utilizando el comando *httpd -V* y, en caso de no extraer la informaci�n necesaria, se establece a **apache**.

## exclude_files

Enumera una lista de los archivos que se eliminar�n a la hora de desplegar el contenido descargado de Subversi�n en su ubicaci�n final.

## exclude_folders

Enumera una lista de los directorios que se eliminar�n a la hora de desplegar el contenido descargado de Subversi�n en su ubicaci�n final.
