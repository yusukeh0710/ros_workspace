FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive 
ENV ROS_DISTRO=humble
ENV ROS_APT_SOURCE_OS=ubuntu
ENV ROS_APT_SOURCE_CODENAME=jammy

RUN apt-get update && apt-get install -y \
    bash \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y \
    python3.12 \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
      -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/${ROS_APT_SOURCE_OS} ${ROS_APT_SOURCE_CODENAME} main" \
      > /etc/apt/sources.list.d/ros2.list

RUN apt-get update && apt-get install -y \
    ros-${ROS_DISTRO}-ros-base \
    ros-${ROS_DISTRO}-rclpy \
    ros-${ROS_DISTRO}-rosbag2-py \
    ros-${ROS_DISTRO}-rosbag2-storage-mcap \
    && rm -rf /var/lib/apt/lists/*

RUN python3.12 -m pip install --no-cache-dir \
    jupyterlab \
    mcap \
    rosdep

# Ensure binary wheels are built for Python 3.12 (avoid loading Ubuntu's dist-packages psutil for 3.10).
RUN python3.12 -m pip install --no-cache-dir --upgrade --force-reinstall psutil

WORKDIR /workspace
COPY entrypoint.sh /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh
EXPOSE 8888

ENTRYPOINT ["./entrypoint.sh"]
