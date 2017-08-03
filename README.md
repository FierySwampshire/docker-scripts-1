# docker-scripts
useful scripts to build, run docker containers

* bdocker.sh - to build docker image
* rdocker.sh - to run docker container
* kill-containers - to kill container(s) of a given docker image name. Use it to kill only locally running docker containers.

## bdocker.sh
This script is used to run `docker build`.

### Usage
	
* Build without tagging to push to ECR
	
	```
	cd my-app
	<path-to-docker-scripts>/bdocker.sh 
	```
	
* Build to push to ECR
	
	```
	cd my-app
	<path-to-docker-scripts>/bdocker.sh ecr
	```
	
### Why use this script?

So what's difference compared to just running `docker build` ?	
##### Automatically tag docker image.
* The docker image is automatically tagged with image name same as name of folder from where it is run.
	For eg.,
	
	```
	cd foo
	<path-to-docker-scripts>/bdocker.sh
	```
	This builds image with tag `foo:latest`.
	
* You can override this with different name by having value for environment variable `$APP_NAME` before running bdocker.sh

```
#!/bin/bash
export APP_NAME=foo2
cd foo
<path-to-docker-scripts>/bdocker.sh
```
	This builds image with tag `foo2:latest`.

* The label can be overriden by exporting value for variable `$IMAGE_LABEL_NAME`

```
#!/bin/bash
export IMAGE_LABEL_NAME=release1
cd foo
<path-to-docker-scripts>/bdocker.sh
```

	This builds image `foo:release1`
	
#### user specific customizations in `~/.bdocker`

* User can list what variable names are used to pick labels. For every environment variable `foo` listed, script checks if `$foo` has value. If yes, it is stored in docker image with label `foo_${APP_NAME}` 
* The environment can be set in `~/.bdocker` file. Please see `.bdocker_example` for reference.  This script is executed 
* You can use this script in Jenkin jobs to add subset of jenkins environment variables as labels by default.

#### Automatically adds below labels
* GIT_BRANCH\_${APP_NAME} - current git branch name
* GIT_COMMIT\_${APP_NAME} - last git commit hash
* BUILD_HOST\_${APP_NAME} - build hostname
* BUILD_TIMESTAMP\_${APP_NAME} - current timestamp when build is run

#### Automatically creates an `image-info-env.sh` file
* The labels are also exported to a file `.image-info-env.sh` in current working directory. This file can be added to docker image as well.
* When built image is used as intermediate docker image in multi-stage builds, labels are not copied over to new image. Hence, it is recommended to add in `Dockerfile` to copy `image-info-env.sh` to directory which will be copied by derived images.

## rdocker.sh

This script is used to run `docker run`

### Usage

* Run docker image

```
./rdocker.sh my-app:latest
```

This script runs the command as
`docker run [-e var1=value1 -e var2=value2 ...] my-app:latest`

* In general you can pass all other arguments you would pass to `docker run` as below

`./rdocker.sh arg1 arg2 ... argN` would be run as

`docker run [-e var1=value1 -e var2=value2 ...] arg1 arg2 ... argN`

### Why use this script?

So what's difference compared to just running `docker run` ?

##### Automatically add environment variables when running docker run command.
* The docker image is automatically tagged with image name same as name of folder from where it is run.
	For eg.,
	
	```
	cd foo
	<path-to-docker-scripts>/bdocker.sh
	```
	This builds image with tag `foo:latest`.


## FAQs

* Should I clone this repo and use these scripts from locally? How do we handle updates to these scripts?

	Build this repo as Docker image by running `./bdocker.sh` and host the container in your container cluster. So you can run the script as below
	
	`curl http://<YOUR_ELB_NAME>/docker-scripts/bdocker.sh | sh -s ecr`

	You can update the scripts in container and all scripts/developers using above line will get updated script.
	
* How to build this image?
	
	Of course use bdocker.sh to build docker image.
	
	```
	git clone git@github.com:GopinathMR/docker-scripts.git
	cd docker-scripts
	
	cp .bdocker_example ~/.bdocker
	# setup your ECR repository url in ~/.bdocker file
	./bdocker.sh ecr
	
	./rdocker.sh -p 80:80 <imagename>
	```