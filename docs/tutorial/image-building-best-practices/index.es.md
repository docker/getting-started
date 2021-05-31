## Escaneo de Seguridad


Cuando haya creado una imagen, es una buena práctica escanearla en busca de vulnerabilidades de seguridad utilizando el 
comando `docker scan`.
Docker se ha asociado con [Snyk](http://snyk.io) para proporcionar el servicio de análisis de vulnerabilidades.

Por ejemplo, para escanear la imagen `getting-started` que creó anteriormente en el tutorial, simplemente escriba

```bash
docker scan getting-started
```

El análisis utiliza una base de datos de vulnerabilidades que se actualiza constantemente, por lo que el resultado que 
ve variará a medida que se descubran nuevas vulnerabilidades, pero podría verse así:

```plaintext
✗ Low severity vulnerability found in freetype/freetype
  Description: CVE-2020-15999
  Info: https://snyk.io/vuln/SNYK-ALPINE310-FREETYPE-1019641
  Introduced through: freetype/freetype@2.10.0-r0, gd/libgd@2.2.5-r2
  From: freetype/freetype@2.10.0-r0
  From: gd/libgd@2.2.5-r2 > freetype/freetype@2.10.0-r0
  Fixed in: 2.10.0-r1

✗ Medium severity vulnerability found in libxml2/libxml2
  Description: Out-of-bounds Read
  Info: https://snyk.io/vuln/SNYK-ALPINE310-LIBXML2-674791
  Introduced through: libxml2/libxml2@2.9.9-r3, libxslt/libxslt@1.1.33-r3, nginx-module-xslt/nginx-module-xslt@1.17.9-r1
  From: libxml2/libxml2@2.9.9-r3
  From: libxslt/libxslt@1.1.33-r3 > libxml2/libxml2@2.9.9-r3
  From: nginx-module-xslt/nginx-module-xslt@1.17.9-r1 > libxml2/libxml2@2.9.9-r3
  Fixed in: 2.9.9-r4
```

El resultado enumera el tipo de vulnerabilidad, una URL para obtener más información y, lo que es más importante, qué 
versión de la biblioteca relevante corrige la vulnerabilidad.

Hay varias otras opciones, sobre las que puede leer en [documentación docker scan](https://docs.docker.com/engine/scan/).

Además de escanear su imagen recién construida en la línea de comando, también puede 
[configurar Docker Hub](https://docs.docker.com/docker-hub/vulnerability-scanning/)
para escanear todas las imágenes recién enviadas automáticamente, y luego puede ver los resultados tanto en Docker Hub 
como en Docker Desktop.

![Escaneo de vulnerabilidades del hub](hvs.png){: style=width:75% }
{: .text-center }

## Capas de imagen

¿Sabías que puedes mirar lo que compone una imagen? Usando el comando `docker image history`, 
puede ver el comando que se usó para crear cada capa dentro de una imagen.

1. Utilice el comando `docker image history` para ver las capas en la imagen de `getting-started` que creó 
   anteriormente en el tutorial.

    ```bash
    docker image history getting-started
    ```

    Debería obtener un resultado que se parezca a esto (los identificadores de fechas pueden ser diferentes).

    ```plaintext
    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    a78a40cbf866        18 seconds ago      /bin/sh -c #(nop)  CMD ["node" "src/index.j…    0B                  
    f1d1808565d6        19 seconds ago      /bin/sh -c yarn install --production            85.4MB              
    a2c054d14948        36 seconds ago      /bin/sh -c #(nop) COPY dir:5dc710ad87c789593…   198kB               
    9577ae713121        37 seconds ago      /bin/sh -c #(nop) WORKDIR /app                  0B                  
    b95baba1cfdb        13 days ago         /bin/sh -c #(nop)  CMD ["node"]                 0B                  
    <missing>           13 days ago         /bin/sh -c #(nop)  ENTRYPOINT ["docker-entry…   0B                  
    <missing>           13 days ago         /bin/sh -c #(nop) COPY file:238737301d473041…   116B                
    <missing>           13 days ago         /bin/sh -c apk add --no-cache --virtual .bui…   5.35MB              
    <missing>           13 days ago         /bin/sh -c #(nop)  ENV YARN_VERSION=1.21.1      0B                  
    <missing>           13 days ago         /bin/sh -c addgroup -g 1000 node     && addu…   74.3MB              
    <missing>           13 days ago         /bin/sh -c #(nop)  ENV NODE_VERSION=12.14.1     0B                  
    <missing>           13 days ago         /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B                  
    <missing>           13 days ago         /bin/sh -c #(nop) ADD file:e69d441d729412d24…   5.59MB   
    ```

    Cada una de las líneas representa una capa en la imagen. La pantalla aquí muestra la base en la parte inferior con 
    la capa más nueva en la parte superior. Con esto, también puede ver rápidamente el tamaño de cada capa, lo que ayuda 
    a diagnosticar imágenes grandes.

1. Notarás que varias de las líneas están truncadas. Si agrega el indicador `--no-trunc`, obtendrá la salida completa 
   (sí ... es curioso cómo usa una bandera truncada para obtener una salida no truncada, ¿eh?)

    ```bash
    docker image history --no-trunc getting-started
    ```


## Almacenamiento en caché de capas

Ahora que ha visto las capas en acción, hay una lección importante que aprender para ayudar a reducir los build
times de las imágenes de su contenedor.

> Una vez que cambia una capa, todas las capas posteriores también deben volver a crearse

Veamos el Dockerfile que estábamos usando una vez más ...

```dockerfile
FROM node:12-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
```

Volviendo a la salida del historial de la imagen, vemos que cada comando en el Dockerfile se convierte en una nueva capa 
en la imagen. Quizás recuerde que cuando hicimos un cambio en la imagen, las dependencias yarn tuvieron que reinstalarse. 
¿Hay alguna forma de solucionar este problema? No tiene mucho sentido distribuir las mismas dependencias cada vez que 
construimos, ¿verdad?

Para solucionar esto, necesitamos reestructurar nuestro Dockerfile para ayudar a soportar el almacenamiento en caché de 
las dependencias. Para aplicaciones Node-based, esas dependencias se definen en el archivo `package.json`. Entonces, 
¿qué pasa si copiamos solo ese archivo primero, instalamos las dependencias y, luego, copiamos todo lo demás? Luego, 
solo recreamos las dependencias yarn si hubo un cambio en el `package.json`. ¿Tener sentido?

1. Actualice el Dockerfile para copiar en el `package.json` primero, instale las dependencias y luego copie todo lo 
   demás en.

    ```dockerfile hl_lines="3 4 5"
    FROM node:12-alpine
    WORKDIR /app
    COPY package.json yarn.lock ./
    RUN yarn install --production
    COPY . .
    CMD ["node", "src/index.js"]
    ```

1. Cree un archivo llamado `.dockerignore` en la misma carpeta que Dockerfile con el siguiente contenido.

    ```ignore
    node_modules
    ```

    Los archivos `.dockerignore` son una manera fácil de copiar selectivamente solo archivos relevantes de imagen.
    Puede leer más sobre esto 
    [aquí](https://docs.docker.com/engine/reference/builder/#dockerignore-file).
    En este caso, la carpeta `node_modules` debe omitirse en el segundo paso `COPY` porque de lo contrario, 
    posiblemente sobrescribirá los archivos que fueron creados por el comando en el paso `RUN`.
    Para obtener más detalles sobre por qué se recomienda esto para las aplicaciones Node.js y otras prácticas 
    recomendadas, echa un vistazo a su guía en
    [Dockerizar una aplicación web Node.js](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/).

1. Cree una nueva imagen usando `docker build`.

    ```bash
    docker build -t getting-started .
    ```

    Debería ver un resultado como este ...

    ```plaintext
    Sending build context to Docker daemon  219.1kB
    Step 1/6 : FROM node:12-alpine
    ---> b0dc3a5e5e9e
    Step 2/6 : WORKDIR /app
    ---> Using cache
    ---> 9577ae713121
    Step 3/6 : COPY package.json yarn.lock ./
    ---> bd5306f49fc8
    Step 4/6 : RUN yarn install --production
    ---> Running in d53a06c9e4c2
    yarn install v1.17.3
    [1/4] Resolving packages...
    [2/4] Fetching packages...
    info fsevents@1.2.9: The platform "linux" is incompatible with this module.
    info "fsevents@1.2.9" is an optional dependency and failed compatibility check. Excluding it from installation.
    [3/4] Linking dependencies...
    [4/4] Building fresh packages...
    Done in 10.89s.
    Removing intermediate container d53a06c9e4c2
    ---> 4e68fbc2d704
    Step 5/6 : COPY . .
    ---> a239a11f68d8
    Step 6/6 : CMD ["node", "src/index.js"]
    ---> Running in 49999f68df8f
    Removing intermediate container 49999f68df8f
    ---> e709c03bc597
    Successfully built e709c03bc597
    Successfully tagged getting-started:latest
    ```

    Verá que se reconstruyeron todas las capas. Perfectamente bien desde que cambiamos bastante el Dockerfile.

1. Ahora, haga un cambio en el archivo `src/static/index.html` (como cambiar el `<title>` para decir "The Awesome Todo App").

1. Cree la imagen de Docker ahora usando `docker build -t Getting started .` nuevamente. Esta vez, su salida debería
   verse un poco diferente.

    ```plaintext hl_lines="5 8 11"
    Sending build context to Docker daemon  219.1kB
    Step 1/6 : FROM node:12-alpine
    ---> b0dc3a5e5e9e
    Step 2/6 : WORKDIR /app
    ---> Using cache
    ---> 9577ae713121
    Step 3/6 : COPY package.json yarn.lock ./
    ---> Using cache
    ---> bd5306f49fc8
    Step 4/6 : RUN yarn install --production
    ---> Using cache
    ---> 4e68fbc2d704
    Step 5/6 : COPY . .
    ---> cccde25a3d9a
    Step 6/6 : CMD ["node", "src/index.js"]
    ---> Running in 2be75662c150
    Removing intermediate container 2be75662c150
    ---> 458e5c6f080c
    Successfully built 458e5c6f080c
    Successfully tagged getting-started:latest
    ```

    Antes que nada, ¡Deberías notar que la construcción fue MUCHO más rápida! Y verá que todos los pasos 1-4 tienen
    "Using cache". Entonces, ¡hurra! Estamos usando la caché de compilación. Pushing y pulling esta imagen y las 
    actualizaciones también será mucho más rápido. ¡Hurra!


## Construcciones Multi-Stage

Si bien no vamos a profundizar demasiado en este tutorial, las compilaciones multi-stage son una herramienta 
increíblemente poderosa para ayudar a usar multiple stages para crear una imagen. Tienen varias ventajas:

- Separe las dependencias en build-time de las dependencias en runtime
- Reduzca el tamaño general de la imagen enviando _solo_ lo que su aplicación necesita para ejecutarse

### Ejemplo Maven/Tomcat

Al crear aplicaciones basadas en Java, se necesita un JDK para compilar el código fuente en código de bytes Java. 
Sin embargo, ese JDK no es necesario en producción. Además, es posible que esté utilizando herramientas como Maven o 
Gradle para ayudar a crear la aplicación. Esos tampoco son necesarios en nuestra imagen final. Las compilaciones de 
varias etapas ayudan.

```dockerfile
FROM maven AS build
WORKDIR /app
COPY . .
RUN mvn package

FROM tomcat
COPY --from=build /app/target/file.war /usr/local/tomcat/webapps 
```

En este ejemplo, usamos una etapa (llamada `build`) para realizar la compilación real de Java usando Maven. En la segunda 
etapa (comenzando en `FROM tomcat`), copiamos archivos de la etapa de `build`. La imagen final es solo la última etapa 
que se está creando (que se puede anular usando el indicador `--target`).


### Ejemplo React

Al crear aplicaciones React, necesitamos un entorno Node para compilar el código JS (normalmente JSX), SASS stylesheets,
y más en HTML, JS, y CSS estático. Si no estamos haciendo renderizado del lado del servidor, ni siquiera necesitamos 
un entorno Node para nuestra compilación de producción. ¿Por qué no enviar los recursos estáticos en un contenedor nginx 
estático?

```dockerfile
FROM node:12 AS build
WORKDIR /app
COPY package* yarn.lock ./
RUN yarn install
COPY public ./public
COPY src ./src
RUN yarn run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
```

Aquí, estamos usando una imagen `node: 12` para realizar la compilación (maximizando el almacenamiento en caché de la 
capa) y luego copiando la salida en un contenedor nginx. Genial, ¿eh?


## Resumen

Al comprender un poco cómo se estructuran las imágenes, podemos crear imágenes más rápido y enviar menos cambios.
El escaneo de imágenes nos da la confianza de que los contenedores que estamos ejecutando y distribuyendo son seguros.
Las compilaciones Multi-stage también nos ayudan a reducir el tamaño general de la imagen y a aumentar la seguridad del 
contenedor final al separar las dependencias en build-time de las dependencias en runtime.