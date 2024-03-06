#!/bin/bash

IMAGE_NAME=moveit_framework
IMAGE_TAG=1.0
NAME=docker_ros_gazebo

chmod +rw ~/.bash_history
chmod o+w ~/.bash_history

WORKSPACE=ros_gazebo_ws

# Create /tmp/.docker.xauth if it does not already exist.
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    touch $XAUTH
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
fi

xhost +

docker run \
    --net=host \
    -v $(pwd):/home/ros/$WORKSPACE \
    --env="HISTFILE=/home/ros/.bash_history" \
    --env="HISTFILESIZE=4000" \
    -v ~/.bash_history:/home/ros/.bash_history \
    --device=/dev/dri:/dev/dri \
    -it \
    --rm \
    --gpus all \
    --env="NVIDIA_VISIBLE_DEVICES=all" \
    --env="NVIDIA_DRIVER_CAPABILITIES=all" \
    --env="DISPLAY=$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --env="XAUTHORITY=$XAUTH" \
    --volume="$XAUTH:$XAUTH" \
    --name $NAME \
    -w /home/ros/$WORKSPACE \
    $IMAGE_NAME:$IMAGE_TAG \
    /bin/bash 