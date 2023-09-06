FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:1.0.14

FROM ghcr.io/js2264/ohca:1.0.0

USER root

COPY scripts $JUPYTER_HOME/scripts

# Add env vars to identify binary package installation
ENV TERRA_R_PLATFORM="terra-jupyter-r-1.1.1"
ENV TERRA_R_PLATFORM_BINARY_VERSION=3.17

# Add R kernel
RUN find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
 && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel /opt/conda/share/jupyter/kernels

## set pip3 to run as root, not as jupyter user
ENV PIP_USER=false

## Install python packages needed for a few Bioc packages
RUN pip3 -V \
    && pip3 install --upgrade pip \
    && pip3 install cwltool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
## pip runs as jupyter user

# Install Bioconductor packages found at:
# https://raw.githubusercontent.com/anvilproject/anvil-docker/master/anvil-rstudio-bioconductor/install.R
RUN R -e 'BiocManager::install(c( \
    "AnVIL", \
    "HiCExperiment", \
    "HiCool", \
    "HiContacts", \
    "HiContactsData", \
    "fourDNData", \
    "DNAZooData"))'
## pip runs as jupyter user

ENV PIP_USER=true

RUN R -e 'IRkernel::installspec(user=FALSE)' \
    && chown -R $USER:users /usr/local/lib/R/site-library /home/jupyter

USER $USER
