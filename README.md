# Introduction.
You can use this project to;
- spin up a docker container using the docker-compose.yml file OR
- use the Dockerfile to create an image for your project and use the generated image in a Container service provider like Azure.


## Using docker-compose option
There are two services.
- Nginx in webserver container
- Php in php container via php-fpm on port 9000

### Install.
Simply execute,  
`docker-compose up -d --build php`

### Webserver  
Webserver is running on port 8080.
To access it provide below url on your browser url bar.  
`http://127.0.0.1:8080/info.php`  
This will show a page with the current php info of the server.

### Nginx
Nginx default config is located at `.docker/nginx/default.conf`

### Xdebug
Xdebug settings are at `.docker/php/conf.d/xdebug.ini`

## Using Dockerfile option
Include any files, folder that should not be added into the final image using the `.dockerignore` file.

To build the image with a tag, use command:  
`docker build -t <name of your image> <path to the Dockerfile>`  
 
ex:     
`docker build -t php-nginx-docker-v1 -f Dockerfile . --progress=plain --no-cache`  

To check our images use;    
`docker images`

An image becomes a container when we execute it, using:  
`docker run -d (or daemon) -p (to expose port 80 in the container to the port 80 on the host machine) <image id>`  
   
`docker run -d drupal-docker`

To view the site  
`docker run -p 80:80 -t drupal-docker`  

To ssh to docker  
`docker run --rm -it drupal-docker bash`  

To push to docker hub
1. Tag it  
   `docker tag <name of the image>  <dockerhub username>/<name of your repo>:<version>`  

- ex:  
`docker tag php-nginx-docker-v1 pasankg/drupal-on-docker:php-nginx-docker-v1`  

2. Push
   `docker push <dockerhub username> / <image name>:<version name>`   
   
- ex:   
`docker push pasankg/drupal-on-docker:php-nginx-docker-v1`


## Useful docker commands.
To clear docker cache  
`docker builder prune`

To remove dangling images  
`docker images -f 'dangling=true' -q | xargs -r docker rmi -f`