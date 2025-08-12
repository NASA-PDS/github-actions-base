# 🌄 PDS Engineering: GitHub Actions Base
# =======================================

FROM python:3.13.5-alpine3.22


# Varaibles and Support
# ---------------------
#
# Set up the various variables and the image metadata.
#
#
# Python Package Pins
# ~~~~~~~~~~~~~~~~~~~
#
# It would be nice to use Alpine's own package manager (`apk`) to install a
# number of Python packages, however, despite the official python:3.13.5 image
# being based on alpine3.22, alpine3.22 itself has standardized on python 3.12.
# Therefore, we have to `pip install` all of our dependencies and avoid the
# apk py3-* packages.

ENV github3_py=4.0.1
ENV lxml=6.0.0
ENV numpy=2.2.3
ENV pandas=2.3.0
ENV requests=2.32.4
ENV sphinx_argparse=0.5.2
ENV sphinx_copybutton=0.5.2
ENV sphinx_rtd_theme=3.0.2
ENV sphinx_substitution_extensions=2025.6.6
ENV sphinx=8.2.3
ENV sphinxcontrib_redoc=1.6.0
ENV twine=6.1.0


# Node.js Package Pins
# ~~~~~~~~~~~~~~~~~~~~

ENV jest=29.7
ENV jsdoc=4.0.2


# Metadata
# ~~~~~~~~

LABEL "repository"="https://github.com/NASA-PDS/github-actions-base.git"
LABEL "homepage"="https://pds-engineering.jpl.nasa.gov/"
LABEL "maintainer"="Sean Kelly <kelly@seankelly.biz>"


# Image Details
# -------------
#
# Note we include some bigger Python packages used by other PDS projects.

COPY m2-repository.tar.bz2 /tmp
WORKDIR /root


# Base packages from the package manager, `apk`
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

RUN : &&\
    mkdir /root/.m2 &&\
    tar x -C /root/.m2 -j -f /tmp/m2-repository.tar.bz2 &&\
    rm /tmp/m2-repository.tar.bz2 &&\
    apk update &&\
    apk add --no-progress --virtual /build ruby-dev make cargo &&\
    apk add --no-progress bash git-lfs gcc g++ musl-dev libxml2 libxslt git ruby ruby-libs ruby-multi_json &&\
    apk add --no-progress openssh-client maven openjdk8 gnupg libgit2-dev libffi-dev libxml2-dev libxslt-dev &&\
    apk add --no-progress openssl-dev npm &&\
    :


# Python packages from `pip`
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~

RUN : &&\
    pip install --quiet --upgrade pip setuptools wheel build &&\
    pip install --quiet github3.py==${github3_py} lxml==${lxml} numpy==${numpy} pandas==${pandas} &&\
    pip install --quiet requests==${requests} sphinx_argparse==${sphinx_argparse} &&\
    pip install --quiet sphinx_copybutton==${sphinx_copybutton} sphinx_rtd_theme==${sphinx_rtd_theme} &&\
    pip install --quiet sphinx_substitution_extensions==${sphinx_substitution_extensions} sphinx==${sphinx} &&\
    pip install --quiet sphinxcontrib_redoc==${sphinxcontrib_redoc} twine==${twine} &&\
    :


# Node.js packages from `npm`
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~

RUN : &&\
    gem install github_changelog_generator --version 1.16.4 &&\
    npm install --save-dev jest@${jest} jsdoc@${jsdoc} &&\
    wget -qP /usr/local/bin https://github.com/X1011/git-directory-deploy/raw/master/deploy.sh &&\
    chmod +x /usr/local/bin/deploy.sh &&\
    apk del /build &&\
    rm -rf /var/cache/apk/* &&\
    : /
