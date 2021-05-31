
En el capítulo anterior, hablamos y usamos un **named volume** para conservar los datos en nuestra base de datos.
Los named volumes son excelentes si simplemente queremos almacenar datos, ya que no tenemos que preocuparnos por 
_dónde_ se almacenan los datos.

Con **bind mounts**, controlamos el punto de montaje exacto en el host. Podemos usar esto para conservar datos, 
pero a menudo se usa para proporcionar datos adicionales en contenedores. Cuando trabajamos en una aplicación, 
podemos usar un bind mount para montar nuestro código fuente en el contenedor para permitirle ver los cambios 
de código, responder y ver los cambios de inmediato.

Para las aplicaciones basadas en Node, [nodemon](https://npmjs.com/package/nodemon) es una gran herramienta para 
observar los cambios de archivos y luego reiniciar la aplicación. Existen herramientas equivalentes en la mayoría 
de los otros lenguajes y frameworks.

## Comparaciones rápidas de tipos de volumen

Los bind mounts y named volumes son los dos tipos principales de volúmenes que vienen con el motor de Docker. 
Sin embargo, hay controladores de volumen adicionales disponibles para admitir otros casos de uso ([SFTP](https://github.com/vieux/docker-volume-sshfs), [Ceph](https://ceph.com/geen-categorie/getting-started-with-the-docker-rbd-volume-plugin/), [NetApp](https://netappdvp.readthedocs.io/en/stable/), [S3](https://github.com/elementar/docker-s3-volume) y más).

|   | Named Volumes | Bind Mounts |
| - | ------------- | ----------- |
| Ubicación del host | Docker elige | Tú controlas |
| Ejemplo de montaje (using `-v`) | my-volume:/usr/local/data | /path/to/data:/usr/local/data |
| Llena un nuevo volumen con el contenido del contenedor. | Si | No |
| Soporta controladores de volumen | Si | No |


## Iniciar un contenedor en modo de desarrollo

Para ejecutar nuestro contenedor para admitir un flujo de trabajo de desarrollo, haremos lo siguiente:

- Monte nuestro código fuente en el contenedor
- Instale todas las dependencias, incluidas las dependencias "dev"
- Inicie nodemon para observar los cambios en el sistema de archivos

¡Hagamoslo!

1. Asegúrese de no tener ningún contenedor de `getting-started` en ejecución.

1. Ejecute el siguiente comando. Explicaremos lo que está pasando después:

    ```bash
    docker run -dp 3000:3000 \
        -w /app -v "$(pwd):/app" \
        node:12-alpine \
        sh -c "yarn install && yarn run dev"
    ```

    Si está utilizando PowerShell, utilice este comando.

    ```powershell
    docker run -dp 3000:3000 `
        -w /app -v "$(pwd):/app" `
        node:12-alpine `
        sh -c "yarn install && yarn run dev"
    ```

    - `-dp 3000:3000` - igual que antes. Ejecuta en modo independiente (en segundo plano) y crea un mapeo de puertos
    - `-w /app` - establece el "directorio de trabajo" o el directorio actual desde el que se ejecutará el comando
    - `-v "$(pwd):/app"` - enlaza la montura al directorio actual desde el host en el contenedor en el directorio `app`
    - `node:12-alpine` - la imagen a usar. Tenga en cuenta que esta es la imagen base para nuestra aplicación del Dockerfile
    - `sh -c "yarn install && yarn run dev"` - el comando. Estamos iniciando un shell usando `sh` (alpine no tiene` bash`) 
      y ejecutando `yarn install` para instalar _todas_ las dependencias y luego ejecutando `yarn run dev`. Si miramos 
      en el `package.json`, veremos que el script `dev` está iniciando `nodemon`.

1. Puede ver los registros usando `docker logs -f <container-id>`. Sabrá que está listo para comenzar cuando vea esto ...

    ```bash
    docker logs -f <container-id>
    $ nodemon src/index.js
    [nodemon] 1.19.2
    [nodemon] to restart at any time, enter `rs`
    [nodemon] watching dir(s): *.*
    [nodemon] starting `node src/index.js`
    Using sqlite database at /etc/todos/todo.db
    Listening on port 3000
    ```

    Cuando haya terminado de ver los registros, salga presionando `Ctrl`+`C`.

1. Ahora, hagamos un cambio en la aplicación. En el archivo `src/static/js/app.js`, cambiemos el botón "Add Item" para que 
   simplemente diga "Add". Este cambio estará en la línea 109.

    ```diff
    -                         {submitting ? 'Adding...' : 'Add Item'}
    +                         {submitting ? 'Adding...' : 'Add'}
    ```

1. Simplemente actualice la página (o ábrala) y debería ver el cambio reflejado en el navegador casi de inmediato. Es 
   posible que el servidor Node demore unos segundos en reiniciarse, por lo que si obtiene un error, intente actualizar 
   después de unos segundos.

    ![Screenshot of updated label for Add button](updated-add-button.png){: style="width:75%;"}
    {: .text-center }

1. No dude en realizar cualquier otro cambio que desee. Cuando haya terminado, detenga el contenedor y cree su nueva 
   imagen usando `docker build -t Getting-started .`.


El uso de bind mounts es _muy_ común para las configuraciones de desarrollo local. La ventaja es que la máquina de 
desarrollo no necesita tener instaladas todas las herramientas y entornos de compilación. Con un solo comando 
"docker run", el entorno de desarrollo se extrae y está listo para funcionar. Hablaremos de Docker Compose en un paso 
futuro, ya que esto ayudará a simplificar nuestros comandos (ya tenemos muchas banderas en nuestros comandos).

## Resumen

En este punto, podemos conservar nuestra base de datos y responder rápidamente a las necesidades y demandas de nuestros 
inversores y fundadores. ¡Hurra! ¿Pero adivina que? ¡Recibimos buenas noticias!

**¡Su proyecto ha sido seleccionado para un futuro desarrollo!** 

Para prepararnos para producción, necesitamos migrar nuestra base de datos de trabajar en SQLite a algo que pueda 
escalar un poco mejor. Para simplificar, mantendremos una base de datos relacional y cambiaremos nuestra aplicación 
para usar MySQL. Pero, ¿cómo deberíamos ejecutar MySQL? ¿Cómo permitimos que los contenedores se comuniquen entre sí? 
¡Hablaremos de eso a continuación!
