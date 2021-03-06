FROM cnpcshangbo/ros-zed-dronekit-cv2:v2
# FROM nvcr.io/nvidia/l4t-base:r32.4.2
# FROM ripl/libbot2-ros:latest

# set the version of the realsense library
ENV LIBREALSENSE_VERSION 2.41.0
ENV LIBREALSENSE_ROS_VERSION 2.2.21

# set working directory
RUN mkdir -p /code
WORKDIR /code

# install dependencies
RUN apt update && \
  DEBIAN_FRONTEND=noninteractive apt install -y \
  wget \
  python-rosinstall \
  python-catkin-tools \
  ros-${ROS_DISTRO}-jsk-tools \
  ros-${ROS_DISTRO}-rgbd-launch \
  ros-${ROS_DISTRO}-image-transport-plugins \
  ros-${ROS_DISTRO}-image-transport \
  libusb-1.0-0 \
  libusb-1.0-0-dev \
  freeglut3-dev \
  libgtk-3-dev \
  libglfw3-dev && \
  # clear cache
  rm -rf /var/lib/apt/lists/*

# install librealsense
RUN cd /tmp && \
  wget https://github.com/IntelRealSense/librealsense/archive/v${LIBREALSENSE_VERSION}.tar.gz && \
  tar -xvzf v${LIBREALSENSE_VERSION}.tar.gz && \
  rm v${LIBREALSENSE_VERSION}.tar.gz && \
  mkdir -p librealsense-${LIBREALSENSE_VERSION}/build && \
  cd librealsense-${LIBREALSENSE_VERSION}/build && \
  cmake ../ -DBUILD_PYTHON_BINDINGS:bool=true -DPYTHON_EXECUTABLE=/usr/bin/python3 && \
  make -j4 && \
  make install && \
  rm -rf librealsense-${LIBREALSENSE_VERSION}

# export PYTHONPATH=$PYTHONPATH:/usr/local/lib
ENV PYTHONPATH=$PYTHONPATH:/usr/local/lib
# install ROS package
RUN mkdir -p /code/src && \
  cd /code/src/ && \
  wget https://github.com/intel-ros/realsense/archive/${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  tar -xvzf ${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  rm ${LIBREALSENSE_ROS_VERSION}.tar.gz && \
  mv realsense-ros-${LIBREALSENSE_ROS_VERSION}/realsense2_camera ./ && \
  rm -rf realsense-${LIBREALSENSE_ROS_VERSION}

# build ROS package
# RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
#   catkin build -j2 --make-args="-j2"

# dependencies for https://github.com/cnpcshangbo/vision_to_mavros
RUN pip3 install transformations && \
  pip3 install apscheduler

RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'

RUN sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN sudo apt update

RUN apt install ros-${ROS_DISTRO}-ddynamic-reconfigure

RUN . /opt/ros/${ROS_DISTRO}/setup.sh && \
  catkin build -j2 --make-args="-j2"
