FROM metasploitframework/metasploit-framework:latest

USER root

RUN apk update && apk add \
    nmap \
    curl \
    wget \
    bind-tools \
    iputils \
    netcat-openbsd \
    vim \
 && ln -s /usr/src/metasploit-framework/msfconsole /usr/local/bin/msfconsole

CMD ["/bin/bash"]