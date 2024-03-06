ARG BASE_IMAGE=osrf/ros
ARG BASE_TAG=noetic-desktop-full

FROM ${BASE_IMAGE}:${BASE_TAG}

RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing \
    ros-noetic-position-controllers \
    ros-noetic-effort-controllers \
    ros-noetic-ros-control \
    ros-noetic-ros-controllers \
    build-essential \
    python3-catkin-tools \
    python3-rosdep \
    ros-noetic-moveit \
    tmux python3-pip\
    nano \
    nautilus

RUN rm /etc/ros/rosdep/sources.list.d/20-default.list \
    && rosdep init \
    && rosdep update

RUN . /opt/ros/noetic/setup.sh \
    && apt-get update

ENV DEBIAN_FRONTEND=dialog

# Create a new user
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt-get update \
    && apt-get install -y sudo \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Change HOME environment variable
ENV TERM=xterm-256color

ENV HOME /home/${USERNAME}

# Choose to run as user
ENV USER ${USERNAME}

USER ${USERNAME}

ARG WORKSPACE=ros_gazebo_ws

WORKDIR /home/${USERNAME}/${WORKSPACE}

# Install the python packages
RUN pip3 install \
    numpy \
    --upgrade

RUN echo "export GAZEBO_RESOURCE_PATH=/home/ros/${WORKSPACE}/src/simple_scene/worlds:$GAZEBO_RESOURCE_PATH" >> ~/.bashrc
RUN echo "export GAZEBO_MODEL_PATH=/home/ros/${WORKSPACE}/src/simple_scene/models:$GAZEBO_MODEL_PATH" >> ~/.bashrc

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /usr/share/gazebo-11/setup.bash" >> ~/.bashrc
RUN echo "if [ -f ~/${WORKSPACE}/devel/setup.bash ]; then source ~/${WORKSPACE}/devel/setup.bash; fi" >> /home/ros/.bashrc
