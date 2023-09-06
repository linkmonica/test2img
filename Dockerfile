FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.1.10
    
# Install Bioconductor packages found at:
# https://raw.githubusercontent.com/anvilproject/anvil-docker/master/anvil-rstudio-bioconductor/install.R
RUN R -e 'BiocManager::install(c( \
    "AnVIL", \
    "basilisk", \
    "HiCExperiment", \
    "HiCool", \
    "HiContacts", \
    "HiContactsData", \
    "fourDNData", \
    "DNAZooData"))'
