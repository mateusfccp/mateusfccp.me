FROM nginx:latest

ARG VERSION=0.55.4

ADD https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_extended_${VERSION}_Linux-64bit.tar.gz /tmp/hugo_bin.tar.gz
RUN tar xvzf /tmp/hugo_bin.tar.gz -C /tmp
RUN cp /tmp/hugo /bin/hugo
RUN rm /tmp/* -r

WORKDIR hugo
COPY hugo .
RUN hugo --gc --minify

