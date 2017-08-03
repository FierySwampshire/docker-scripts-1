#!/bin/bash

declare -a labels=("GIT_BRANCH" "GIT_COMMIT" "BUILD_HOST" "BUILD_TIMESTAMP" )

if [ -f ~/.bdocker ]; then
    source ~/.bdocker
fi

if [ ! -f Dockerfile ]; then
    echo "ERROR!!! $PWD/Dockerfile not found"
    exit 1
fi

if [ "$APP_NAME" == "" ]; then
    export APP_NAME=`basename $PWD`
fi

if [ "$IMAGE_LABEL_NAME" == "" ]; then
    export IMAGE_LABEL_NAME="latest"
fi

# Putting default values when running locally
if [ "$IMAGE_TAG_NAME" == "" ]; then
    if [ "$1" == "ecr" ]; then
        # locally creating image to push to ecr
        export IMAGE_TAG_NAME="$ECR_REGISTRY/$APP_NAME:$IMAGE_LABEL_NAME"
    else
        export IMAGE_TAG_NAME="$APP_NAME:$IMAGE_LABEL_NAME"
    fi
fi

# in-built variables
if [ "$GIT_BRANCH" == "" ]; then
    export GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
fi

if [ "$GIT_COMMIT" == "" ]; then
    export GIT_COMMIT=`git rev-parse HEAD`
fi

if [ "$BUILD_HOST" == "" ]; then
    export BUILD_HOST=`hostname`
fi

if [ "$BUILD_TIMESTAMP" == "" ]; then
    export BUILD_TIMESTAMP=`date -u`
fi

export docker_build_cmd="docker build -t $IMAGE_TAG_NAME "

if [ -f .image-info.txt ]; then
    rm -f .image-info.txt
fi

echo "#!/bin/bash" >> .image-info-env.sh
for label_name in "${labels[@]}"
do
    if [ ! "${!label_name}" == "" ]; then
        export docker_build_cmd="$docker_build_cmd --label ${label_name}_${APP_NAME}='${!label_name}'"
        echo "export ${label_name}_${APP_NAME}=${!label_name}" >> .image-info-env.sh
    fi
done

export docker_build_cmd="$docker_build_cmd ."

echo "Starting docker command : $docker_build_cmd"
eval "$docker_build_cmd"

rm -f .image-info-env.sh
