## Security Scanning

When you have built an image, it is good practice to scan it for security vulnerabilities using the `docker scan` command.
Docker has partnered with [Snyk](http://snyk.io) to provide the vulnerability scanning service.

For example, to scan the `getting-started` image you created earlier in the tutorial, you can just type

```bash
docker scan getting-started
```

The scan uses a constantly updated database of vulnerabilities, so the output you see will vary as new
vulnerabilities are discovered, but it might look something like this:

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

The output lists the type of vulnerability, a URL to learn more, and importantly which version of the relevant library
fixes the vulnerability.

There are several other options, which you can read about in the [docker scan documentation](https://docs.docker.com/engine/scan/).

As well as scanning your newly built image on the command line, you can also [configure Docker Hub](https://docs.docker.com/docker-hub/vulnerability-scanning/)
to scan all newly pushed images automatically, and you can then see the results in both Docker Hub and Docker Desktop.

![Hub vulnerability scanning](hvs.png){: style=width:75% }
{: .text-center }

## Image Layering

Did you know that you can look at how an image is composed? Using the `docker image history`
command, you can see the command that was used to create each layer within an image.

1. Use the `docker image history` command to see the layers in the `getting-started` image you
   created earlier in the tutorial.

    ```bash
    docker image history getting-started
    ```

    You should get output that looks something like this (dates/IDs may be different).

    ```plaintext
    IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
    05bd8640b718   53 minutes ago   CMD ["node" "src/index.js"]                     0B        buildkit.dockerfile.v0
    <missing>      53 minutes ago   RUN /bin/sh -c yarn install --production # b…   83.3MB    buildkit.dockerfile.v0
    <missing>      53 minutes ago   COPY . . # buildkit                             4.59MB    buildkit.dockerfile.v0
    <missing>      55 minutes ago   WORKDIR /app                                    0B        buildkit.dockerfile.v0
    <missing>      10 days ago      /bin/sh -c #(nop)  CMD ["node"]                 0B        
    <missing>      10 days ago      /bin/sh -c #(nop)  ENTRYPOINT ["docker-entry…   0B        
    <missing>      10 days ago      /bin/sh -c #(nop) COPY file:4d192565a7220e13…   388B      
    <missing>      10 days ago      /bin/sh -c apk add --no-cache --virtual .bui…   7.85MB    
    <missing>      10 days ago      /bin/sh -c #(nop)  ENV YARN_VERSION=1.22.19     0B        
    <missing>      10 days ago      /bin/sh -c addgroup -g 1000 node     && addu…   152MB     
    <missing>      10 days ago      /bin/sh -c #(nop)  ENV NODE_VERSION=18.12.1     0B        
    <missing>      11 days ago      /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
    <missing>      11 days ago      /bin/sh -c #(nop) ADD file:57d621536158358b1…   5.29MB 
    ```

    Each line represents a layer in the image. The display here shows the base at the bottom with
    the newest layer at the top. Using this you can also quickly see the size of each layer, helping to
    diagnose large images.

1. You'll notice that several of the lines are truncated. If you add the `--no-trunc` flag, you'll get the
   full output (yes... funny how you use a truncated flag to get untruncated output, huh?)

    ```bash
    docker image history --no-trunc getting-started
    ```


## Layer Caching

Now that you've seen the layering in action, there's an important lesson to learn to help decrease build
times for your container images.

> Once a layer changes, all downstream layers have to be recreated as well

Let's look at the Dockerfile we were using one more time...

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN yarn install --production
CMD ["node", "src/index.js"]
```

Going back to the image history output, we see that each command in the Dockerfile becomes a new layer in the image.
You might remember that when we made a change to the image, the yarn dependencies had to be reinstalled. Is there a
way to fix this? It doesn't make much sense to ship around the same dependencies every time we build, right?

To fix this, we need to restructure our Dockerfile to help support the caching of the dependencies. For Node-based
applications, those dependencies are defined in the `package.json` file. So what if we start by copying only that file in first,
install the dependencies, and _then_ copy in everything else? Then, we only recreate the yarn dependencies if there was
a change to the `package.json`. Make sense?

1. Update the Dockerfile to copy in the `package.json` first, install dependencies, and then copy everything else in.

    ```dockerfile hl_lines="3 4 5"
    FROM node:18-alpine
    WORKDIR /app
    COPY package.json yarn.lock ./
    RUN yarn install --production
    COPY . .
    CMD ["node", "src/index.js"]
    ```

1. Create a file named `.dockerignore` in the same folder as the Dockerfile with the following contents.

    ```ignore
    node_modules
    ```

    `.dockerignore` files are an easy way to selectively copy only image relevant files.
    You can read more about this
    [here](https://docs.docker.com/engine/reference/builder/#dockerignore-file).
    In this case, the `node_modules` folder should be omitted in the second `COPY` step because otherwise
    it would possibly overwrite files which were created by the command in the `RUN` step.
    For further details on why this is recommended for Node.js applications as well as further best practices,
    have a look at their guide on
    [Dockerizing a Node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/).

1. Build a new image using `docker build`.

    ```bash
    docker build -t getting-started .
    ```

    You should see output like this...

    ```plaintext
    [+] Building 16.1s (10/10) FINISHED
    => [internal] load build definition from Dockerfile                                               0.0s
    => => transferring dockerfile: 175B                                                               0.0s
    => [internal] load .dockerignore                                                                  0.0s
    => => transferring context: 2B                                                                    0.0s
    => [internal] load metadata for docker.io/library/node:18-alpine                                  0.0s
    => [internal] load build context                                                                  0.8s
    => => transferring context: 53.37MB                                                               0.8s
    => [1/5] FROM docker.io/library/node:18-alpine                                                    0.0s
    => CACHED [2/5] WORKDIR /app                                                                      0.0s
    => [3/5] COPY package.json yarn.lock ./                                                           0.2s
    => [4/5] RUN yarn install --production                                                           14.0s
    => [5/5] COPY . .                                                                                 0.5s 
    => exporting to image                                                                             0.6s 
    => => exporting layers                                                                            0.6s 
    => => writing image sha256:d6f819013566c54c50124ed94d5e66c452325327217f4f04399b45f94e37d25        0.0s 
    => => naming to docker.io/library/getting-started                                                 0.0s
    ```

    You'll see that all layers were rebuilt. Perfectly fine since we changed the Dockerfile quite a bit.

1. Now, make a change to the `src/static/index.html` file (like change the `<title>` to say "The Awesome Todo App").

1. Build the Docker image now using `docker build -t getting-started .` again. This time, your output should look a little different.

    ```plaintext hl_lines="10 11 12"
    [+] Building 1.2s (10/10) FINISHED
    => [internal] load build definition from Dockerfile                                               0.0s
    => => transferring dockerfile: 37B                                                                0.0s
    => [internal] load .dockerignore                                                                  0.0s
    => => transferring context: 2B                                                                    0.0s
    => [internal] load metadata for docker.io/library/node:18-alpine                                  0.0s
    => [internal] load build context                                                                  0.2s
    => => transferring context: 450.43kB                                                              0.2s
    => [1/5] FROM docker.io/library/node:18-alpine                                                    0.0s
    => CACHED [2/5] WORKDIR /app                                                                      0.0s
    => CACHED [3/5] COPY package.json yarn.lock ./                                                    0.0s
    => CACHED [4/5] RUN yarn install --production                                                     0.0s
    => [5/5] COPY . .                                                                                 0.5s
    => exporting to image                                                                             0.3s
    => => exporting layers                                                                            0.3s
    => => writing image sha256:91790c87bcb096a83c2bd4eb512bc8b134c757cda0bdee4038187f98148e2eda       0.0s
    => => naming to docker.io/library/getting-started                                                 0.0s
    ```

    First off, you should notice that the build was MUCH faster! You'll see that several steps are using
    previously cached layers. So, hooray! We're using the build cache. Pushing and pulling this image and updates to it
    will be much faster as well. Hooray!


## Multi-Stage Builds

While we're not going to dive into it too much in this tutorial, multi-stage builds are an incredibly powerful
tool which help us by using multiple stages to create an image. They offer several advantages including:

- Separate build-time dependencies from runtime dependencies
- Reduce overall image size by shipping _only_ what your app needs to run

### Maven/Tomcat Example

When building Java-based applications, a JDK is needed to compile the source code to Java bytecode. However,
that JDK isn't needed in production. You might also be using tools such as Maven or Gradle to help build the app.
Those also aren't needed in our final image. Multi-stage builds help.

```dockerfile
FROM maven AS build
WORKDIR /app
COPY . .
RUN mvn package

FROM tomcat
COPY --from=build /app/target/file.war /usr/local/tomcat/webapps 
```

In this example, we use one stage (called `build`) to perform the actual Java build with Maven. In the second
stage (starting at `FROM tomcat`), we copy in files from the `build` stage. The final image is only the last stage
being created (which can be overridden using the `--target` flag).


### React Example

When building React applications, we need a Node environment to compile the JS code (typically JSX), SASS stylesheets,
and more into static HTML, JS, and CSS. Although if we aren't performing server-side rendering, we don't even need a Node environment
for our production build. Why not ship the static resources in a static nginx container?

```dockerfile
FROM node:18 AS build
WORKDIR /app
COPY package* yarn.lock ./
RUN yarn install
COPY public ./public
COPY src ./src
RUN yarn run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
```

Here, we are using a `node:18` image to perform the build (maximizing layer caching) and then copying the output
into an nginx container. Cool, huh?


## Recap

By understanding a little bit about how images are structured, we can build images faster and ship fewer changes.
Scanning images gives us confidence that the containers we are running and distributing are secure.
Multi-stage builds also help us reduce overall image size and increase final container security by separating
build-time dependencies from runtime dependencies.
