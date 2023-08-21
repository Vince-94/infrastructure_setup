#! base-stage
ARG UBUNTU_RELEASE

FROM ubuntu:$UBUNTU_RELEASE as base-stage

ARG DEBIAN_FRONTEND=noninteractive

ARG UBUNTU_USER=docker_user
ARG UBUNTU_PSW=docker
ARG UBUNTU_UID=1000
ARG UBUNTU_GID=1000

ENV UBUNTU_USER=$UBUNTU_USER
ENV UBUNTU_PSW=$UBUNTU_PSW
ENV UBUNTU_UID=$UBUNTU_UID
ENV UBUNTU_GID=1000

# Create local user docker_user
RUN useradd -r -m -d /home/$UBUNTU_USER -s /bin/bash -g root -G sudo -G dialout -u $UBUNTU_UID -p "$(openssl passwd -6 $UBUNTU_PSW)" $UBUNTU_USER

# Add local user to system groups
RUN usermod -aG sudo $UBUNTU_USER
RUN usermod -aG dialout $UBUNTU_USER
RUN usermod -aG tty $UBUNTU_USER
RUN usermod -aG audio $UBUNTU_USER
RUN usermod -aG video $UBUNTU_USER

# Update
# RUN add-apt-repository universe
RUN apt update && \
	apt upgrade -y


########################
# INSTALL DEPENDENCIES #
########################

# Ubuntu deps
RUN apt install --quiet -y \
    sudo software-properties-common lsb-release \
    apt-transport-https ca-certificates gnupg gnupg2 gnupg-agent libssl-dev \
    curl file wget zip unzip pkg-config openssh-client openssh-server \
    xterm tmux gdb valgrind \
    htop net-tools nmap

# C++ deps
RUN apt install --quiet -y \
    build-essential \
    clang \
    cmake \
    ccache

# C++ linter
RUN apt install --quiet -y \
    clang-tidy clang-tools \
    cppcheck

# C++ testing deps
RUN apt install --quiet -y \
    libgtest-dev \
    libgmock-dev \
    lcov

# Python deps
RUN apt install --quiet -y \
    python3 \
    python3-dev \
    python3-pip

RUN pip3 install --upgrade \
    wheel \
    setuptools \
    argcomplete

# Python linter
RUN pip3 install --upgrade \
    pylint \
    flake8 \
    mypy

RUN pip3 install --upgrade \
    pytest \
    pytest-mock \
    pytest-cov pytest-html \
    pytest-pep8 \
    pytest-pylint \
    pytest-flake8

RUN pip3 install --upgrade \
    pandas tk matplotlib \
    pyyaml \
    numpy scipy

# Python system control deps
# RUN pip3 install --upgrade \
#     qpsolvers \
#     quadprog gurobipy osqp cvxopt cvxpy

# # install CVXOPT (https://cvxopt.org/)
# RUN pip3 install --upgrade cvxopt

# # install CVXPY (https://www.cvxpy.org/index.html)
# RUN pip3 install --upgrade cvxpy

# # install Guroby ()
# RUN pip3 install --upgrade gurobipy

# # install osqp ()
# RUN pip3 install --upgrade osqp


# Bazel (https://bazel.build/install/ubuntu)
# RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel-archive-keyring.gpg
# RUN mv bazel-archive-keyring.gpg /usr/share/keyrings
# RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
# RUN apt update && apt install --quiet -y bazel

# Open html links
RUN sudo apt install lynx


##############
# ENTRYPOINT #
##############

# Clean
RUN apt -y autoremove \
	&& apt clean autoclean \
	&& rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Set user
USER $UBUNTU_USER
WORKDIR /home/$UBUNTU_USER

# Set entrypoint
COPY ./docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

ENV force_color_prompt=yes
CMD ["bash"]