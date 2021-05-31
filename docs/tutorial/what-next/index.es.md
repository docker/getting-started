
Aunque hemos terminado con nuestro taller, ¡todavía hay MUCHO más que aprender sobre los contenedores! 
No vamos a profundizar aquí, ¡pero aquí hay algunas otras áreas para ver a continuación!

## Orquestación de contenedores

Running containers in production is tough. No desea iniciar sesión en una máquina y simplemente ejecutar un `docker run`
o un` docker-compose up`. ¿Por qué no? Bueno, ¿qué pasa si los contenedores mueren? ¿Cómo escalas en varias máquinas? La
orquestación de contenedores resuelve este problema. Herramientas como Kubernetes, Swarm, Nomad y ECS ayudan a resolver
este problema, todas de formas ligeramente diferentes.

La idea general es que tienes "managers" que reciben el **estado esperado**. Este estado podría ser "Quiero ejecutar dos 
instancias de mi aplicación web y exponer el puerto 80". Luego, los managers examinan todas las máquinas del clúster y 
delegan el trabajo a los nodos "worker". Los managers observan los cambios (como la salida de un contenedor) y luego 
trabajan para que el **actual state** refleje el estado esperado.


## Proyectos de la Cloud Native Computing Foundation

El CNCF es un hogar vendor-neutral para varios proyectos de código abierto, incluidos Kubernetes, Prometheus, Envoy, 
Linkerd, NATS y más! Puede ver los [proyectos graduados e incubados aquí](https://www.cncf.io/projects/) y el 
[Landscape CNCF aquí](https://landscape.cncf.io/). ¡Hay MUCHOS proyectos para ayudar a resolver problemas relacionados 
con el monitoreo, logging, la seguridad, image registries, la mensajería y más!

Por lo tanto, si es nuevo en el landscape de contenedores y el desarrollo de aplicaciones cloud-native, ¡bienvenido! 
¡Conéctese con la comunidad, haga preguntas y siga aprendiendo! ¡Estamos emocionados de tenerte!
