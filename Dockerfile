FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:1.0.14

USER root

COPY scripts $JUPYTER_HOME/scripts

# Add env vars to identify binary package installation
ENV TERRA_R_PLATFORM="terra-jupyter-r-1.1.1"
ENV TERRA_R_PLATFORM_BINARY_VERSION=3.17

# Add R kernel
RUN find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
 && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel /opt/conda/share/jupyter/kernels

# https://cran.r-project.org/bin/linux/ubuntu/README.html
RUN && apt-get install -yq --no-install-recommends \
add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/' \
apt-utils \
 	python3.7 \
	libssh2-1-dev \
	libssl-dev \
	libcurl4-gnutls-dev \
	libgit2-dev \
	libxml2-dev \
	libgfortran-7-dev \
	r-base-dev \
	r-base-core



# DEVEL: Add sys env variables to DEVEL image
# Variables in Renviron.site are made available inside of R.
# Add libsbml CFLAGS
ENV LIBSBML_CFLAGS="-I/usr/include"
ENV LIBSBML_LIBS="-lsbml"
RUN echo 'export LIBSBML_CFLAGS="-I/usr/include"' >> /etc/profile \
    && echo 'export LIBSBML_LIBS="-lsbml"' >> /etc/profile

## set pip3 to run as root, not as jupyter user
ENV PIP_USER=false

## Install python packages needed for a few Bioc packages
RUN pip3 -V \
    && pip3 install --upgrade pip \
    && pip3 install cwltool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN R -e 'install.packages("BiocManager")' \
    ## check version
    && R -e 'BiocManager::install(version="3.17", ask=FALSE)' \
    && R -e 'BiocManager::install(c( \
    "boot", \
    "class", \
    "cluster", \
    "codetools", \
    "foreign", \
    "kernsmooth", \
    "lattice", \
    "mass", \
    "Matrix", \
    "mgcv", \
    "nlme", \
    "nnet", \
    "rpart", \
    "Seurat", \
    "spatial", \
    "survival", \
    # Jupyter notebook essentials
    "IRdisplay",  \
    "IRkernel", \
    # GCP essentials
    "bigrquery",  \
    "googleCloudStorageR", \
    # User oriented packages
    "reticulate", \
    "remotes", \
    "devtools", \
    "tidyverse", \
    "pbdZMQ", \
    "uuid"))' \
    && R -e 'BiocManager::install("DataBiosphere/Ronaldo")'
    
# Install Bioconductor packages found at:
# https://raw.githubusercontent.com/anvilproject/anvil-docker/master/anvil-rstudio-bioconductor/install.R
RUN R -e 'BiocManager::install(c( \
    "AnVIL", \
    "HiCExperiment", \
    "HiCool", \
    "HiContacts", \
    "HiContactsData", \
    "fourDNData", \
    "DNAZooData", \
    "GenomicFeatures", \
    "impute", \
    "preprocessCore", \
    "GO.db", \
    "GenomicInteractions", \
    "ensembldb"))'
    
RUN R -e "install.packages('terra')"
RUN R -e "install.packages('WGCNA')"
RUN R -e "devtools::install_github('js2264/OHCA')"  
## pip runs as jupyter user
ENV PIP_USER=true

RUN R -e 'IRkernel::installspec(user=FALSE)' \
    && chown -R $USER:users /usr/local/lib/R/site-library /home/jupyter

USER $USER
