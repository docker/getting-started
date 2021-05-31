---
next_page: app.md
---

## El comando que acabas de ejecutar

¡Felicidades! ¡Ha iniciado el contenedor para este tutorial!
Primero expliquemos el comando que acaba de ejecutar. En caso de que lo hayas olvidado
aquí está el comando:

```cli
docker run -d -p 80:80 docker/getting-started
```

Notará que se utilizan algunas banderas. Aquí hay más información sobre ellas:

- `-d` - ejecuta el contenedor en modo separado (en segundo plano)
- `-p 80:80` - mapea el puerto 80 del host al puerto 80 en el contenedor
- `docker/getting-started` - la imagen a usar

!!! info "Consejo profesional"
    Puede combinar banderas de un solo carácter para acortar el comando completo.
    Como ejemplo, el comando anterior podría escribirse como:
    ```
    docker run -dp 80:80 docker/getting-started
    ```

## El panel de Docker

Antes de ir demasiado lejos, queremos resaltar el panel de Docker, que le brinda 
una vista rápida de los contenedores que se ejecutan en su máquina. Le brinda acceso 
rápido a los registros del contenedor, le permite obtener un shell dentro del 
contenedor y le permite administrar fácilmente el ciclo de vida del contenedor (detener, 
eliminar, etc.).

Para acceder al panel, siga las instrucciones para 
[Mac](https://docs.docker.com/docker-for-mac/dashboard/) o 
[Windows](https://docs.docker.com/docker-for-windows/dashboard/). Si abre el panel ahora, 
verá este tutorial en ejecución. El nombre del contenedor (`jolly_bouman` a continuación) 
es un nombre creado al azar. Por lo tanto, lo más probable es que tenga un nombre diferente.

![Tutorial container running in Docker Dashboard](tutorial-in-dashboard.png)


## ¿Qué es un contenedor?

Ahora que ha ejecutado un contenedor, que _es_ un contenedor? En pocas palabras, un contenedor es 
simplemente otro proceso en su máquina que ha sido aislado de todos los demás procesos en la máquina host. 
Ese aislamiento aprovecha [kernel namespaces y cgroups](https://medium.com/@saschagrunert/demystifying-containers-part-i-kernel-space-2c53d6979504), características que han estado 
en Linux durante mucho tiempo. Docker ha trabajado para hacer que estas capacidades sean accesibles y fáciles de usar.

!!! info "Creación de contenedores desde cero"
    Si desea ver cómo se construyen los contenedores desde cero, Liz Rice de Aqua Security
    tiene una charla fantástica en la que crea un contenedor desde cero en Go. Si bien hace 
    un contenedor simple, esta charla no se relaciona con las redes, el uso de imágenes para 
    el sistema de archivos y más. Pero ofrece una _fantástica_ inmersión en el modo en que 
    funcionan las cosas.

    <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/8fi7uSYlOdc" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## ¿Qué es una imagen de contenedor?

Cuando se ejecuta un contenedor, utiliza un sistema de archivos aislado. Este sistema de 
archivos personalizado es proporcionado por una **imagen de contenedor**. Dado que la 
imagen contiene el sistema de archivos del contenedor, debe contener todo lo necesario 
para ejecutar una aplicación: todas las dependencias, configuración, scripts, binarios, 
etc. La imagen también contiene otra configuración para el contenedor, como variables de 
entorno, un comando predeterminado para ejecutar, y otros metadatos.

Más adelante profundizaremos en las imágenes, cubriendo temas como capas, mejores prácticas y más.

!!! info
    Si está familiarizado con `chroot`, piense en un contenedor como una versión extendida de` chroot`. 
    El sistema de archivos simplemente proviene de la imagen. Pero, un contenedor agrega aislamiento 
    adicional que no está disponible cuando simplemente se usa chroot.