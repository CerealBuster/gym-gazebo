FROM tensorflow/tensorflow

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

#----------------------
# General dependencies
#----------------------

RUN apt-get update && apt-get install -y \
wget\
&& rm -rf /var/lib/apt/lists/*

#-------------
# Keras setup
#-------------
RUN pip install keras

#-----------
# ROS setup
#-----------
# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list

#install Ros desktop
RUN apt-get update && apt-get install -y \
ros-kinetic-desktop

#Initialize rosedp
RUN rosdep init && rosdep update

#Environment setup

RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
#RUN /bin/bash -c source /opt/ros/kinetic/setup.bash

#Dependencies for building packages
RUN apt-get install -y \
python-rosinstall python-rosinstall-generator python-wstool build-essential \
&& rm -rf /var/lib/apt/lists/*


#-------------
# Dependencies
#-------------

RUN apt-get update && apt-get install -y \
cmake gcc g++ qt4-qmake libqt4-dev \
libusb-dev libftdi-dev \
python3-pip python3-pyqt4 python3-defusedxml python3-vcstool \
ros-kinetic-octomap-msgs        \
ros-kinetic-joy                 \
ros-kinetic-geodesy             \
ros-kinetic-octomap-ros         \
ros-kinetic-control-toolbox     \
ros-kinetic-pluginlib	       \
ros-kinetic-trajectory-msgs     \
ros-kinetic-control-msgs	       \
ros-kinetic-std-srvs 	       \
ros-kinetic-nodelet	       \
ros-kinetic-urdf		       \
ros-kinetic-rviz		       \
ros-kinetic-kdl-conversions     \
ros-kinetic-eigen-conversions   \
ros-kinetic-tf2-sensor-msgs     \
ros-kinetic-pcl-ros \
ros-kinetic-navigation\
&& rm -rf /var/lib/apt/lists/*

RUN pip3 install rospkg catkin_pkg
RUN pip install scikit-image

#----------------
#Install Gazebo8
#----------------
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'

RUN wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -

RUN apt-get update && apt-get install -y \
gazebo8 \
libgazebo8-dev \
&& rm -rf /var/lib/apt/lists/*

# setup environment
EXPOSE 11345

#---------------
# Intall GZWEB
#---------------

# install packages
RUN apt-get update && apt-get install -q -y \
    build-essential \
    cmake \
    imagemagick \
    libboost-all-dev \
    libgts-dev \
    libjansson-dev \
    libtinyxml-dev \
    mercurial \
    nodejs \
    nodejs-legacy \
    npm \
    pkg-config \
    psmisc \
    xvfb\
&& rm -rf /var/lib/apt/lists/*

# clone gzweb
ENV GZWEB_WS /root/gzweb
RUN hg clone https://bitbucket.org/osrf/gzweb $GZWEB_WS
WORKDIR $GZWEB_WS

# build gzweb
RUN hg up default \
    && xvfb-run -s "-screen 0 1280x1024x24" ./deploy.sh -m -t

# setup environment
EXPOSE 8080
EXPOSE 7681

#-------------
# Install gym
#-------------

RUN pip install gym

#----------------
# Install Sophus
#----------------
WORKDIR /opt

RUN git clone https://github.com/stonier/sophus -b release/0.9.1-kinetic

WORKDIR /opt/sophus/build/

RUN cmake .. && make && make install

#--------------------
# Install gym-gazebo
#--------------------
WORKDIR /opt

COPY . gym-gazebo/

WORKDIR /opt/gym-gazebo/gym_gazebo/envs/installation/
RUN bash setup_kinetic.bash

WORKDIR /opt/gym-gazebo/
RUN pip install -e .

WORKDIR /opt/gym-gazebo/gym_gazebo/envs/installation/
RUN bash turtlebot_setup.bash


#-------------------
# Setup environment
#-------------------
WORKDIR /opt
ENV ROS_PORT_SIM 11311