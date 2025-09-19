FROM docker.io/library/ubuntu:20.04

USER root

RUN apt-get -y update

RUN apt-get install -y gnupg

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | tee /etc/apt/sources.list.d/mono-official-stable.list

RUN apt-get install -y mono-devel gtk-sharp2 libappindicator0.1-cil libmono-2.0-1 wget apt-transport-https nano git-core software-properties-common dirmngr

RUN wget https://github.com/duplicati/duplicati/releases/download/v2.0.8.1-2.0.8.1_beta_2024-05-07/duplicati_2.0.8.1-1_all.deb

RUN apt-get -y install ./duplicati_2.0.8.1-1_all.deb

ENTRYPOINT ["/usr/bin/duplicati-server"]

CMD ["--webservice-interface=any", "--webservice-port=8200", "--portable-mode", "--server-datafolder=/duplicati", "--webservice-allowed-hostnames=*"]