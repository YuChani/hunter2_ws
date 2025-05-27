# 1. Base image: Ubuntu 22.04
FROM ubuntu:22.04

# 2. 환경 변수
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV ROS_DISTRO=humble

# 3. 필수 패키지 설치
RUN apt update && apt install -y \
    locales \
    curl \
    gnupg2 \
    lsb-release \
    git \
    wget \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    build-essential \
    libeigen3-dev \
    libboost-all-dev \
    libopencv-dev \
    python3-opencv \
    dbus-x11 \
    libgl1-mesa-glx \
    libx11-xcb1 \
    nano \
    net-tools \
    iputils-ping \
    bash-completion \
    software-properties-common \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# 4. ROS 2 Humble 설치
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | \
    gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list && \
    apt update && \
    apt install -y ros-humble-desktop

# 5. ROS 2 관련 유틸리티 패키지 설치
RUN apt update && apt install -y \
    ros-humble-gazebo-* \
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-ackermann-steering-controller \
    ros-humble-control-* \
    ros-humble-rqt-robot-steering \
    && rm -rf /var/lib/apt/lists/*

# 6. ROS 환경 적용
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc
SHELL ["/bin/bash", "-c"]

# 7. rosdep 초기화
RUN rosdep init && rosdep update

# 8. hunter2_ws 레포 클론
WORKDIR /root
RUN git clone https://github.com/YuChani/hunter2_ws.git
WORKDIR /root/hunter2_ws

# 9. 의존성 설치 및 빌드
RUN source /opt/ros/humble/setup.bash && \
    rosdep install --from-paths src --ignore-src -r -y && \
    colcon build --symlink-install

# 10. 환경 자동 로드
RUN echo "source /root/hunter2_ws/install/setup.bash" >> /root/.bashrc

CMD ["bash"]

