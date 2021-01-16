# Stage 1: testing =============================================================
# This stage will contain the minimal dependencies for the CI/CD environment to
# run the test suite:

# Use the official Ruby 2.7.1 Slim Buster image as base:
FROM ruby:2.7.2-slim-buster AS testing

# Install the app build system dependency packages:
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential git

# Receive the app path as an argument:
ARG CODE_PATH=/code/on-container

# Receive the developer user's UID and USER:
ARG DEVELOPER_UID=1000
ARG DEVELOPER_USERNAME=you

# Replicate the developer user in the development image:
RUN addgroup --gid ${DEVELOPER_UID} ${DEVELOPER_USERNAME} \
 ;  useradd -r -m -u ${DEVELOPER_UID} --gid ${DEVELOPER_UID} \
    --shell /bin/bash -c "Developer User,,," ${DEVELOPER_USERNAME}

# Ensure the developer user's home directory and APP_PATH are owned by him/her:
# (A workaround to a side effect of setting WORKDIR before creating the user)
RUN userhome=$(eval echo ~${DEVELOPER_USERNAME}) \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} $userhome \
 && mkdir -p ${CODE_PATH} \
 && chown -R ${DEVELOPER_USERNAME}:${DEVELOPER_USERNAME} ${CODE_PATH}

# Add the library's "bin/" directory to PATH:
ENV PATH=${CODE_PATH}/bin:$PATH

# Set the code path as the working directory:
WORKDIR ${CODE_PATH}

# Change to the developer user:
USER ${DEVELOPER_USERNAME}

# Copy the project's Gemfile and Gemfile.lock files:
COPY --chown=${DEVELOPER_USERNAME} on_container.gemspec Gemfile* ${CODE_PATH}/

# Copy the project's gem version file 
COPY --chown=${DEVELOPER_USERNAME} lib/on_container/version.rb ${CODE_PATH}/lib/on_container/

# Install the gems in the Gemfile, except for the ones in the "development"
# group, which shouldn't be required in order to  run the tests with the leanest
# Docker image possible:
RUN bundle install --jobs=4 --retry=3 --without="development"

# Stage 2: Development =========================================================
# In this stage we'll add the packages, libraries and tools required in the
# day-to-day development process.
FROM testing AS development

# Change to root user to install the development packages:
USER root

# Install sudo, along with any other tool required at development phase:
RUN apt-get install -y --no-install-recommends \
  # Vim will be used to edit files when inside the container (git, etc):
  vim \
  # Sudo will be used to install/configure system stuff if needed during dev:
  sudo

# Receive the developer username - note that ARGS won't persist between stages
# on non-buildkit builds:
ARG DEVELOPER_USERNAME=you

# Add the developer user to the sudoers list:
RUN echo "${DEVELOPER_USERNAME} ALL=(ALL) NOPASSWD:ALL" | tee "/etc/sudoers.d/${DEVELOPER_USERNAME}"

# Change back to the developer user:
USER ${DEVELOPER_USERNAME}

# Install the gems in the Gemfile, this time including the previously ignored
# "development" gems - We'll need to delete the bundler config, as it currently
# belongs to "root":
RUN bundle install --jobs=4 --retry=3 --with="development"
