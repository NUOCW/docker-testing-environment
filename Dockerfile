FROM nuocw/buildpack-deps:centos7
MAINTAINER "TOIDA Yuto" <toida.yuto@b.mbox.nagoya-u.ac.jp>

ENV PHP_54_LATEST=5.4.45
ENV PHP_55_LATEST=5.5.30
ENV PHP_56_LATEST=5.6.16
ENV PHP_70_LATEST=7.0.0RC8

# dependencies for building php
RUN yum update -y && yum install -y epel-release && yum clean all
RUN yum update -y && yum install -y \
    bison \
	libmcrypt-devel \
	libtidy-devel \
	re2-devel \
	&& yum clean all

## add user "nuocw"
#RUN useradd nuocw
#USER nuocw
#ENV HOME="/home/nuocw"
ENV HOME="/root"
WORKDIR ${HOME}

# install anyenv
RUN git clone https://github.com/riywo/anyenv .anyenv
ENV ANYENV_ROOT="${HOME}/.anyenv"
ENV ANYENV_ENV="${ANYENV_ROOT}/envs"
RUN echo 'export PATH="${ANYENV_ROOT}/bin:${PATH}"' >> .bash_profile
RUN echo 'eval "$(anyenv init -)"' >> .bash_profile

# update anyenv
RUN mkdir -p .anyenv/plugins
RUN git clone https://github.com/znz/anyenv-update.git ${ANYENV_ROOT}/plugins/anyenv-update
# RUN git clone https://github.com/ngyuki/phpenv-composer.git ${ANYENV_ROOT}/plugins/anyenv-composer

ENV PATH="${HOME}/.anyenv/bin:${PATH}"
RUN eval "$(anyenv init -)"

# phpenv
RUN anyenv install phpenv
ENV PHPENV_ROOT=${ANYENV_ENV}/phpenv
ENV PATH="${PHPENV_ROOT}/bin:${PHPENV_ROOT}/shims:${PATH}"
# RUN git clone https://github.com/ngyuki/phpenv-composer.git ${PHPENV_ROOT}/plugins/phpenv-composer
RUN eval "$(anyenv init -)"
RUN phpenv install $PHP_54_LATEST && phpenv rehash
RUN phpenv install $PHP_55_LATEST && phpenv rehash
RUN phpenv install $PHP_56_LATEST && phpenv rehash
RUN phpenv install $PHP_70_LATEST && phpenv rehash
RUN phpenv global $PHP_56_LATEST
RUN mkdir ${HOME}/bin && curl -sS https://getcomposer.org/installer | php -- --install-dir=${HOME}/bin --filename=composer
RUN echo 'export PATH=${HOME}/bin:${PATH}' >> .bash_profile
ENV PATH=${HOME}/bin:${PATH}
RUN rm -rf /tmp/php-build


CMD ["/bin/bash", "-c"]
