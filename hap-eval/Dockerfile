FROM continuumio/miniconda3

RUN apt-get -y update \
    && conda install -c conda-forge -y python-levenshtein \
	&& git clone --recurse-submodules https://github.com/Sentieon/hap-eval.git \
    && pip install ./hap-eval
