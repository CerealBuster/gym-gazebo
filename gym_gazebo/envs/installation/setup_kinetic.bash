#!/bin/bash

if [ -z "$ROS_DISTRO" ]; then
  echo "ROS not installed. Check the installation steps: https://github.com/erlerobot/gym#installing-the-gazebo-environment"
fi

program="gazebo"
condition=$(which $program 2>/dev/null | grep -v "not found" | wc -l)
if [ $condition -eq 0 ] ; then
    echo "Gazebo is not installed. Check the installation steps: https://github.com/erlerobot/gym#installing-the-gazebo-environment"
fi

source /opt/ros/kinetic/setup.bash

# Create catkin_ws
ws="../../../catkin_ws"
if [ -d $ws ]; then
  echo "Error: catkin_ws directory already exists" 1>&2
fi
src=$ws"/src"
mkdir -p $src
cd $src
catkin_init_workspace


# Import and build dependencies
vcs import < ../../gym_gazebo/envs/installation/gazebo.repos

cd ..

#Create CATKIN_IGNORE files in kobuki_qtestsuite, wiimote and spacenav_node so we can compile

touch src/kobuki_desktop/kobuki_qtestsuite/CATKIN_IGNORE
touch src/joystick_drivers/wiimote/CATKIN_IGNORE
touch src/joystick_drivers/spacenav_node/CATKIN_IGNORE

catkin_make --pkg mav_msgs
source devel/setup.bash
catkin_make -j 1

bash -c 'echo source `pwd`/devel/setup.bash >> ~/.bashrc'
echo "## ROS workspace compiled ##"

# add own models path to gazebo models path
if [ -z "$GAZEBO_MODEL_PATH" ]; then
  bash -c 'echo "export GAZEBO_MODEL_PATH="`pwd`/../../gym_gazebo/envs/assets/models >> ~/.bashrc'
  exec bash #reload bashrc
fi
