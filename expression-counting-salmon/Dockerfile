FROM ubuntu:20.04 

LABEL org.opencontainers.image.source https://github.com/dnj01208/icgc-docker-push-test
LABEL org.opencontainers.image.authors Dabin Jeong
LABEL org.opencontainers.image.title ICGC ARGO RNA-Seq expression counting image

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y tzdata build-essential wget python3.7 python3-pip tar cmake 
RUN apt install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN apt install -y r-base 

ENV DEBCONF_NOWARNINGS yes 
ARG DEBIAN_FRONTEND=noninteractive

# Download reference transcriptome, genome, gene-annotation
#RUN python -v
#RUN mkdir ref 
#RUN cd ref && \
#    wget http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_37/gencode.v37.annotation.gtf.gz &&\
#    gunzip gencode.v37.annotation.gtf.gz 
#RUN cd ref && \ 
#    wget http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_37/gencode.v37.transcripts.fa.gz &&\
#    gunzip gencode.v37.transcripts.fa.gz
#RUN cd ref && \
#    wget http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_37/GRCh38.p13.genome.fa.gz &&\
#    gunzip GRCh38.p13.genome.fa.gz


RUN mkdir tools

# install HTseq
RUN pip install HTseq

# install featureCounts
RUN apt-get install -y subread

# install kallisto
RUN apt-get install -y kallisto

#install STAR ==> /tools/STAR-2.7.9a/bin/Linux_x86_64
RUN cd /tools &&\
    wget https://github.com/alexdobin/STAR/archive/2.7.9a.tar.gz && \
    gunzip 2.7.9a.tar.gz &&\
    tar -xvf 2.7.9a.tar &&\
    cd STAR-2.7.9a/source &&\
    make STAR

#install rsem
RUN cd /tools && \
    wget https://github.com/deweylab/RSEM/archive/refs/tags/v1.3.3.tar.gz && \
    tar -xvf v1.3.3.tar.gz && \
    cd RSEM-1.3.3 && \
    make

# install salmon 
RUN cd /tools && \
    wget https://github.com/COMBINE-lab/salmon/releases/download/v1.5.2/salmon-1.5.2_linux_x86_64.tar.gz && \
    gunzip salmon-1.5.2_linux_x86_64.tar.gz && \
    tar -xvf salmon-1.5.2_linux_x86_64.tar 

# install stringTie
RUN cd tools &&\
    wget http://ccb.jhu.edu/software/stringtie/dl/stringtie-2.1.7.tar.gz &&\
    tar -xzvf stringtie-2.1.7.tar.gz &&\
    cd stringtie-2.1.7 && \
    make release 
    
RUN pip install pandas && \
    pip install argparse   
    
RUN R -e "install.packages('BiocManager',repos='http://cran.us.r-project.org'); library('BiocManager'); BiocManager::install('rhdf5'); BiocManager::install('tximport')"
RUN R -e "install.packages('argparse')"

# set environmental variables
ENV PATH="$PATH:/tools/:/usr/local/bin:/tools/STAR-2.7.9a/bin/Linux_x86_64:/tools/RSEM-1.3.3/:/tools/stringtie-2.1.7:/tools/salmon-1.5.2_linux_x86_64/bin"


COPY *.py /tools/
COPY *.R /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
