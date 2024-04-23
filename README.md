<div style="width:100%;float:left;clear:both;margin-bottom:50px;">
    <a href="https://github.com/pabloripoll?tab=repositories">
        <img style="width:150px;float:left;" src="https://pabloripoll.com/files/logo-light-100x300.png"/>
    </a>
</div>

# NodeJS 21+ Service

The objective of this repository is having a CaaS [Containers as a Service](https://www.ibm.com/topics/containers-as-a-service) to provide a "ready to use" container with the basic enviroment features to deploy any application service under a lightweight Linux Alpine image with Nginx server platform and [NODE JS](https://nodejs.org/en) for development stage requirements.

The container configuration is as [Host Network](https://docs.docker.com/network/drivers/host/) on `eth0` as [Bridge network](https://docs.docker.com/network/drivers/bridge/), thus it can be accessed through `localhost:${PORT}` by browsers but to connect with it or this with other services `${HOSTNAME}:${PORT}` will be required.

## Container Service

- [NODE JS 21.6](https://www.php.net/releases/8.3/en.php)

- [Nginx 1.24](https://nginx.org/)

- [Alpine Linux 3.19](https://www.alpinelinux.org/)

### Project objetives with Docker

* Built on the lightweight and secure Alpine 3.19 [2024 release](https://www.alpinelinux.org/posts/Alpine-3.19.1-released.html) Linux distribution
* Multi-platform, supporting AMD4, ARMv6, ARMv7, ARM64
* Very small Docker image size (+/-40MB)
* Uses NodeJS 21.6 as default for the best performance, low CPU usage & memory footprint, but also can be downgraded till required NodeJS version
* Optimized for 100 concurrent users
* The services Nginx, NodeJS and Supervisord run under a project-privileged user to make it more secure
* The logs of all the services are redirected to the output of the Docker container (visible with `docker logs -f <container name>`)
* Follows the KISS principle (Keep It Simple, Stupid) to make it easy to understand and adjust the image to your needs
* Service independency to build any application under NodeJS.

#### Containers on Windows systems

This project has not been tested on Windows OS neither I can use it to test it. So, I cannot bring much support on it.

Anyway, using this repository you will needed to find out your PC IP by login as an `administrator user` to set connection between containers.

```bash
C:\WINDOWS\system32>ipconfig /all

Windows IP Configuration

 Host Name . . . . . . . . . . . . : 191.128.1.41
 Primary Dns Suffix. . . . . . . . : paul.ad.cmu.edu
 Node Type . . . . . . . . . . . . : Peer-Peer
 IP Routing Enabled. . . . . . . . : No
 WINS Proxy Enabled. . . . . . . . : No
 DNS Suffix Search List. . . . . . : scs.ad.cs.cmu.edu
```

Take the first ip listed. Wordpress container will connect with database container using that IP.

#### Containers on Unix based systems

Find out your IP on UNIX systems and take the first IP listed
```bash
$ hostname -I

191.128.1.41 172.17.0.1 172.20.0.1 172.21.0.1
```

## Structure

Directories and main files on a tree architecture description. Main `/docker` directory has `/nginx-php` directory separated in case of needing to be included other container service directory with its specific contents
```
.
│
├── docker
│   ├── front (nodejs service)
│   │   ├── docker
│   │   │   ├── config
│   │   │   ├── .env
│   │   │   ├── docker-compose.yml
│   │   │   └── Dockerfile
│   │   │
│   │   └── Makefile
│   │
│   └── (other...)
│
├── resources
│   ├── doc
│   │   └── (any documentary file...)
│   │
│   └── project
│       └── (any file or directory required for re-building the app...)
│
├── project
│   └── (application...)
│
├── .env
├── .env.example
└── Makefile
```

## Automation with Makefile

Makefiles are often used to automate the process of building and compiling software on Unix-based systems as Linux and macOS.

*On Windows - I recommend to use Makefile: \
https://stackoverflow.com/questions/2532234/how-to-run-a-makefile-in-windows*

Makefile recipies
```bash
$ make help
usage: make [target]

targets:
Makefile  help                  shows this Makefile help message
Makefile  hostname              shows local machine ip
Makefile  fix-permission        sets Frontend directory permission
Makefile  host-check            shows this Frontend ports availability on local machine
Makefile  front-ssh             enters the Frontend container shell
Makefile  front-set             sets the Frontend enviroment file to build the container
Makefile  front-create          creates the Frontend container from Docker image
Makefile  front-start           starts the Frontend container running
Makefile  front-dev             creates the Frontend container from Docker image
Makefile  front-stop            stops the Frontend container but data will not be destroyed
Makefile  front-destroy         removes the Frontend from Docker network destroying its data and Docker image
Makefile  front-install         installs set version of Frontend into container
Makefile  front-update          updates set version of Frontend into container
Makefile  repo-flush            clears local git repository cache specially to update .gitignore
```

## Ready to use

As default this repository has an [project/index.html](project/index.html) as welcome test page

Inside [docker/front/Makefile](docker/front/Makefile) there are two variables to install and update a Vite application

```bash
APPLICATION_UPDATE="npm i"
APPLICATION_INSTALL='npm create vite@5.2.3 .'
```

But it can be changed to use any other NodeJS application
```bash
APPLICATION_UPDATE="npm i"
APPLICATION_INSTALL='npm install -g @angular/cli .'
```

This repository comes with Makefile recipe to automate the intallation commands inside running container
```bash
$ make front-install
```

Another **alternative approach** is to perform a manually installation accessing to container shell
```bash
$ make front-ssh

/var/www/htdocs $
/var/www/htdocs $ npm create vite@latest
/var/www/htdocs $ npm install --save-dev vue-router
/var/www/htdocs $ npm install --save axios vue-axios
/var/www/htdocs $ npm i && npm run dev
```

The container service in binded to local [project](project) directory but to proceed any frontend application installation it should be removed its content

## NodeJS as Frontend Service

**Important**: Set NodeJS development stage to show the Docker internal IP and Port as the following example because the exposed container port is for static files
```js
import { defineConfig, loadEnv } from 'vite'

export default defineConfig(({ command, mode }) => {

    return {
        server: {
            host: true
        }
    }
})
```

To set the other static directory than project root edit Nginx server block at [docker/front/docker/config/conf.d/default.conf](docker/front/docker/config/conf.d/default.conf) as the following example
```
server {
    charset      utf-8;

    listen 80;
    listen [::]:80;

    server_name  localhost;

    location / {
        root   /var/www/htdocs/build;

        index  index.html index.htm;
    }
}
```
