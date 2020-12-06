# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.148.1/containers/ruby/.devcontainer/base.Dockerfile

# [Choice] Ruby version: 2, 2.7, 2.6, 2.5
ARG VARIANT="2"
FROM mcr.microsoft.com/vscode/devcontainers/ruby:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends automake autoconf xmlto xsltproc libkrb5-dev libldap2-dev libsasl2-dev

# [Optional] Uncomment this line to install additional gems.
RUN gem install rake bundler rake-compiler rspec && \
    gem install radcli -v 1.1.0

