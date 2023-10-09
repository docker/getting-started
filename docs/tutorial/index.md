---
next_page: app.md
---

## The command you just ran

Congratulations! You have started the container for this tutorial!
Let's first explain the command that you just ran. In case you forgot,
here's the command:

```cli
docker run -d -p 80:80 docker/getting-started
```

You'll notice a few flags being used. Here's some more info on them:

- `-d` - run the container in detached mode (in the background)
- `-p 80:80` - map port 80 of the host to port 80 in the container
- `docker/getting-started` - the image to use

!!! info "Pro tip"
    You can combine single character flags to shorten the full command.
    As an example, the command above could be written as:
    ```
    docker run -dp 80:80 docker/getting-started
    ```

## The Docker Dashboard

Before going any further, we want to highlight the Docker Dashboard, which gives
you a quick view of the containers running on your machine. It provides you 
access to container logs, lets you get a shell inside the container, and allows you to easily manage container lifecycle (stop, remove, etc.). 

To access the dashboard, follow the instructions in the 
[Docker Desktop manual](https://docs.docker.com/desktop/). If you open the dashboard
now, you will see this tutorial running! The container name (`jolly_bouman` below) is a
randomly created name. So, you'll most likely have a different name.

![Tutorial container running in Docker Dashboard](tutorial-in-dashboard.png)


## What is a container?

Now that you've successfully run a container, let's ask ourselves what _is_ a container? Simply put, a container is
another process on your machine that has been isolated from all other processes
on the host machine. That isolation leverages [kernel namespaces and cgroups](https://medium.com/@saschagrunert/demystifying-containers-part-i-kernel-space-2c53d6979504), features that have been 
in Linux for a long time. Docker has worked to make these capabilities approachable and easy to use.

!!! info 
    "Creating Containers from Scratch"
    If you'd like to see how containers are built from scratch, Liz Rice from Aqua Security
    has a fantastic talk in which she creates a container from scratch in Go. While she makes
    a simple container, this talk doesn't go into networking, using images for the filesystem, 
    and more. But, it gives a _fantastic_ deep dive into how things are working.

    <iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/8fi7uSYlOdc" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## What is a container image?

When running a container, it uses an isolated filesystem. This custom filesystem is provided 
by a **container image**. Since the image contains the container's filesystem, it must include everything 
needed to run the application - all dependencies, configuration, scripts, binaries, etc. The 
image also contains other configuration for the container, such as environment variables,
a default command to run, and other metadata.

We'll dive deeper into images later on, covering topics such as layering, best practices, and more.

!!! info
    If you're familiar with `chroot`, think of a container as an extended version of `chroot`. The
    filesystem is simply coming from the image whereas a container adds additional isolation that is not
    available when simply using chroot.

