ARG BASE_IMAGE_REPO
ARG BASE_IMAGE_TAG

FROM $BASE_IMAGE_REPO:$BASE_IMAGE_TAG

ARG DOCKER_IMAGE
ARG DOCKER_TAG_SUFFIX

# Add other dependencies
USER root
RUN apt-get update \
    && apt-get install -y \
    build-essential \
    python-dev \
    swig  \
    libffi-dev  \
    libssl-dev  \
    python-m2crypto  \
    python-httplib2 \
    # pip dependencies that require build deps
    && sudo -H -u odoo pip install --user --no-cache-dir pyOpenSSL M2Crypto httplib2>=0.7 git+https://github.com/pysimplesoap/pysimplesoap@stable_py3k \
    # purge
    && apt-get purge -yqq build-essential '*-dev' make || true \
    && apt-get -yqq autoremove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# fix 'dh key too small' error https://stackoverflow.com/questions/38015537/python-requests-exceptions-sslerror-dh-key-too-small
RUN sed  -i "s/CipherString = DEFAULT@SECLEVEL=2/#CipherString = DEFAULT@SECLEVEL=2/" /etc/ssl/openssl.cnf

USER odoo

# Add new entrypoints and configs
COPY entrypoint.d/* $RESOURCES/entrypoint.d/
COPY conf.d/* $RESOURCES/conf.d/
COPY resources/$ODOO_VERSION/* $RESOURCES/

# Aggregate new repositories of this image
RUN autoaggregate --config "$RESOURCES/repos.yml" --install --output $SOURCES/repositories
