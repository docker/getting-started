
Ahora que hemos creado una imagen, ¡compartámosla! Para compartir imágenes de Docker, 
debe utilizar un Docker registry. El registry predeterminado es Docker Hub y es de 
donde provienen todas las imágenes que hemos utilizado.

## Crear un repositorio

Para enviar una imagen, primero debemos crear un repositorio en Docker Hub.

1. Vaya a [Docker Hub](https://hub.docker.com) e inicie sesión si es necesario.

1. Haga clic en el botón **Create Repository**.

1. Para el nombre del repositorio, use `getting-started`. Asegúrese de que la visibilidad sea `Public`.

1. ¡Haga clic en el botón **Create**!

Si miras en el lado derecho de la página, verás una sección llamada **Docker commands**. Esto proporciona
un comando de ejemplo que deberá ejecutar para enviarlo a este repositorio.

![Docker command with push example](push-command.png){: style=width:75% }
{: .text-center }

## Empujando nuestra imagen

1. En la línea de comandos, intente ejecutar el comando push que ve en Docker Hub. Tenga en cuenta que su comando 
   utilizará su namespace, no "docker".

    ```plaintext
    $ docker push docker/getting-started
    The push refers to repository [docker.io/docker/getting-started]
    An image does not exist locally with the tag: docker/getting-started
    ```

    ¿Por qué falló? El comando push buscaba una imagen llamada docker/getting-started, pero 
    no encontró una. Si ejecuta `docker image ls`, tampoco verá ninguna.

    Para solucionar este problema, necesitamos "etiquetar" nuestra imagen existente que hemos 
    creado para darle otro nombre.

1. Inicie sesión en Docker Hub usando el comando `docker login -u YOUR-USER-NAME`.

1. Use el comando `docker tag` para darle un nuevo nombre a la imagen de `getting-started`. Asegúrese de cambiar 
   `YOUR-USER-NAME` por su ID de Docker.

    ```bash
    docker tag getting-started YOUR-USER-NAME/getting-started
    ```

1. Ahora intente su comando push de nuevo. Si está copiando el valor de Docker Hub, puede eliminar la parte 
   `tagname`, ya que no agregamos una etiqueta al nombre de la imagen. Si no especifica una etiqueta, Docker 
   usará una etiqueta llamada `latest`.

    ```bash
    docker push YOUR-USER-NAME/getting-started
    ```

## Ejecutando nuestra imagen en una nueva instancia

Ahora que nuestra imagen se ha creado y enviado a un registry, ¡intentemos ejecutar nuestra aplicación en 
una instancia nueva que nunca ha visto esta imagen de contenedor! Para hacer esto, usaremos Play with Docker.

1. Abra su navegador en [Play with Docker](http://play-with-docker.com).

1. Inicie sesión con su cuenta de Docker Hub.

1. Una vez que haya iniciado sesión, haga clic en el enlace "+ ADD NEW INSTANCE" en la barra lateral izquierda. (Si no lo ve, amplíe un poco su navegador). Después de unos segundos, se abrirá una ventana de terminal en su navegador.

    ![Play with Docker add new instance](pwd-add-new-instance.png){: style=width:75% }
{: .text-center }


1. En la terminal, inicie su aplicación recién lanzada.

    ```bash
    docker run -dp 3000:3000 YOUR-USER-NAME/getting-started
    ```

    ¡Debería ver que la imagen se baja y finalmente se inicia!

1. Haga clic en la insignia 3000 cuando aparezca y debería ver la aplicación con sus modificaciones. ¡Hurra!
    Si la insignia 3000 no aparece, puede hacer clic en el botón "Open Port" y escribir 3000.

## Resumen

En esta sección, aprendimos cómo compartir nuestras imágenes empujándolas a un registry. Luego fuimos a una 
nueva instancia y pudimos ejecutar la imagen recién enviada. Esto es bastante común en las CI pipelines, donde 
el pipeline creará la imagen y la enviará a un registry y luego el entorno de producción puede usar la última 
versión de la imagen.

Ahora que lo hemos resuelto, volvamos a lo que notamos al final de la última sección. Como recordatorio, notamos 
que cuando reiniciamos la aplicación, perdimos todos los elementos de nuestra lista de tareas pendientes. Obviamente, 
esa no es una gran experiencia de usuario, ¡así que aprendamos cómo podemos conservar los datos durante los reinicios!