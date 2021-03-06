# FROM 指令用于指定后续构建 image 所使用的基础 image
# 这里指定 openjdk 作为基础 image，便不再需要配置 JDK 环境了
# FROM ubuntu:18.04
FROM ubuntu:16.04

# ARG 用于指定传递给构建运行时的变量
# sdk-tools 的版本，版本号在 https://developer.android.com/studio/index.html 页面查看
ARG SDK_TOOLS_VERSION=4333796
# build-tools 的版本
ARG BUILD_TOOLS_VERSION=28.0.3
# 指定 compileSdkVersion 的值
ARG COMPILE_SDK_VERSION=28

# WORDDIR 用于在容器内设置一个工作目录，之后的一些命令都会在这个目录下执行
WORKDIR /project

# ENV 用于设置一个环境变量，之后的命令可以使用
# 指定 Android SDK 的路径
ENV ANDROID_HOME /project/sdk

# 切换阿里云
COPY ./sources.list /etc/apt/sources.list

# 安装必要工具
RUN apt-get update --fix-missing
RUN apt-get install -y wget unzip openssh-client maven git
RUN rm -rf /var/lib/apt/lists/*

# # RUN apt-get install -y bash git wget openssh-client && rm -rf /var/lib/apt/lists/*

# # 安装 Android SDK 和后续构建所需的工具
RUN mkdir sdk && \
    wget https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    unzip -qd sdk sdk-tools-linux-${SDK_TOOLS_VERSION}.zip && \
    rm -f sdk-tools-linux-${SDK_TOOLS_VERSION}.zip

RUN (yes | ./sdk/tools/bin/sdkmanager --no_https --update) && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "build-tools;${BUILD_TOOLS_VERSION}") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "platform-tools") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "platforms;android-${COMPILE_SDK_VERSION}") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;google;m2repository") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;android;m2repository") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2") && \
    (yes | ./sdk/tools/bin/sdkmanager --no_https "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2")

