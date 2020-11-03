# 🌄 PDS Engineering: GitHub Actions Base
# =======================================

FROM python:3.8.5-alpine3.12


# Support
# -------
#
# Commit-Specific Pins
# ~~~~~~~~~~~~~~~~~~~~

ENV github_changelog_commit 322e30a78115ab948e358cd916a9f78e55fe21c1


# Python Package Pins
# ~~~~~~~~~~~~~~~~~~~

ENV sphinx          3.2.1
ENV twine           3.2.0
ENV github3_py      1.3.0
ENV pds_github_util 0.13.0


# Java Minutiae
# ~~~~~~~~~~~~~
#
# If we change the version of Java installed below (see "Image Details"), you
# may need to update JAVA_HOME.

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk


# Metadata
# ~~~~~~~~

LABEL "repository"="https://github.com/NASA-PDS/github-actions-base.git"
LABEL "homepage"="https://pds-engineering.jpl.nasa.gov/"
LABEL "maintainer"="Sean Kelly <kelly@seankelly.biz>"


# Image Details
# -------------
#
# Watch out for that ``pds-github-util``: its dependencies are *huge* 😮
# And they take forver to build 😫

COPY m2-repository.tar.bz2 /tmp
RUN : &&\
    mkdir /root/.m2 &&\
    tar x -C /root/.m2 -j -f /tmp/m2-repository.tar.bz2 &&\
    rm /tmp/m2-repository.tar.bz2 &&\
    apk update &&\
    apk add --no-progress --virtual /build openssl-dev libxml2-dev libxslt-dev libffi-dev ruby-dev make &&\
    apk add --no-progress gcc g++ musl-dev libxml2 libxslt git ruby ruby-etc ruby-json ruby-multi_json ruby-io-console ruby-bigdecimal openssh-client openjdk11-jdk maven gnupg &&\
    pip install --upgrade \
        pip setuptools wheel \
        sphinx==${sphinx} \
        twine==${twine} \
        github3.py==${github3_py} \
        pds-github-util==${pds_github_util} &&\
    cd /usr/src &&\
    git clone https://github.com/github-changelog-generator/github-changelog-generator.git &&\
    cd github-changelog-generator &&\
    git checkout ${github_changelog_commit} &&\
    gem build github_changelog_generator.gemspec &&\
    gem install github_changelog_generator-1.15.2.gem --source https://rubygems.org &&\
    cd .. &&\
    rm -r github-changelog-generator &&\
    apk del /build &&\
    rm -rf /var/cache/apk/* &&\
    : /
