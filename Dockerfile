FROM osrf/ros:humble-desktop

#Uncomment the following line if you get the "release file is not valid yet" error during apt-get
#	(solution from: https://stackoverflow.com/questions/63526272/release-file-is-not-valid-yet-docker)
#RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | cat > /etc/apt/apt.conf.d/10no--check-valid-until

#Install essential
RUN apt-get update && apt-get install -y

##You may add additional apt-get here
RUN sudo apt install nano net-tools openssh-client vsftpd -y
RUN sudo apt install openssh-client -y
RUN sudo apt install python3-colcon-common-extensions -y
RUN sudo apt install ros-humble-librealsense2* -y
RUN sudo apt install ros-humble-realsense2-* -y
RUN sudo apt install ros-humble-rtabmap-ros -y
RUN sudo apt install ros-humble-mavros -y
RUN sudo apt install ros-humble-mavros-extras -y
RUN sudo apt install ros-humble-octomap-rviz-plugins -y
RUN sudo apt install ros-humble-fastcdr -y
RUN sudo apt install ros-dev-tools -y
RUN sudo apt install ros-humble-ros-gz-bridge -y

#Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV HOME /home/user
ENV ROS_DISTRO=humble

#Add non root user using UID and GID passed as argument
ARG USER_ID
ARG GROUP_ID
RUN addgroup --gid $GROUP_ID user
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID user
RUN echo "user:user" | chpasswd
RUN echo "user ALL=(ALL:ALL) ALL" >> /etc/sudoers

#get access to video
RUN sudo usermod -a -G video user

USER user

#Install PX4 
WORKDIR ${HOME}
RUN mkdir src 
WORKDIR ${HOME}/src
RUN git clone https://github.com/PX4/PX4-Autopilot.git --recursive 
WORKDIR ${HOME}/src/PX4-Autopilot/Tools/setup
RUN echo "user" | sudo -S ./ubuntu.sh
RUN pip3 install kconfiglib && pip3 install --user pyros-genmsg && pip3 install --user jinja2 && pip3 install --user jsonschema
RUN pip3 install --user future
WORKDIR ${HOME}/src/PX4-Autopilot
RUN make px4_sitl DONT_RUN=1

WORKDIR ${HOME}
RUN git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git && cd Micro-XRCE-DDS-Agent && mkdir build 

WORKDIR ${HOME}/Micro-XRCE-DDS-Agent/build 
RUN cmake .. && make
RUN echo "user" | sudo -S make install 
WORKDIR ${HOME}/ros2_ws
RUN echo "user" | sudo -S sudo ldconfig /usr/local/lib/

#ROS2 workspace creation and compilation
RUN mkdir -p ${HOME}/ros2_ws/src
WORKDIR ${HOME}/ros2_ws
COPY --chown=user ./src ${HOME}/ros2_ws/src
SHELL ["/bin/bash", "-c"] 
WORKDIR ${HOME}/ros2_ws/src
RUN git clone https://github.com/PX4/px4_msgs.git
# RUN git clone https://github.com/PX4/px4_ros_com.git

RUN source /opt/ros/${ROS_DISTRO}/setup.bash; rosdep update; rosdep install -i --from-path src --rosdistro humble -y; colcon build --symlink-install

RUN echo "user" | sudo -S sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN echo "user" | sudo -S curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo -S apt-key add -
RUN echo "user" | sudo -S apt-get update
RUN echo "user" | sudo -S sudo apt install ros-humble-ros-gz -y

RUN git clone https://github.com/PX4/px4_ros_com.git
WORKDIR ${HOME}/ros2_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash; source install/setup.bash; colcon build 

#Add script source to .bashrc
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash;" >>  ${HOME}/.bashrc
RUN echo "source ${HOME}/ros2_ws/install/local_setup.bash;" >>  ${HOME}/.bashrc

#Clean image
USER root
RUN rm -rf /var/lib/apt/lists/*
USER user