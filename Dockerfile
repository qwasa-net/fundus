FROM eclipse-temurin:21-jdk

ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/gradle/bin

ARG CMDLINE_TOOLS_VERSION=11076708
ARG GRADLE_VERSION=8.10.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY Dockerfile _cached_download[s]/ /tmp/_cached/

# Install Android command line tools
RUN mkdir -pv ${ANDROID_HOME}/cmdline-tools \
    && f=/tmp/_cached/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip \
    && if [ ! -f "$f" ]; then \
        curl -fsSL \
        -o "$f" \
        https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip; \
    fi \
    && unzip -q "$f" -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && ls -l ${ANDROID_HOME}/cmdline-tools/latest

# Accept licenses and install SDK components
RUN yes | sdkmanager --licenses > /dev/null \
    && sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# Install Gradle
RUN f=/tmp/_cached/gradle-${GRADLE_VERSION}-bin.zip \
    && if [ ! -f "$f" ]; then \
        curl -fsSL -o "$f" \
        https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip; \
    fi \
    && cp -v "$f" /opt/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip /opt/gradle-${GRADLE_VERSION}-bin.zip -d /opt \
    && mv /opt/gradle-${GRADLE_VERSION} /opt/gradle \
    && ls -l /opt/

# sdk must be writable for any host uid
RUN chmod -R a+rwX ${ANDROID_HOME}

# cleanup
RUN rm -rfv /tmp/_cached

WORKDIR /workspace
