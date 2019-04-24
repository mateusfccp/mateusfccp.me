FROM nginx:1.15.12


ADD https://github.com/gohugoio/hugo/releases/download/v0.55.3/hugo_extended_0.55.3_Linux-64bit.tar.gz /tmp/hugo_bin.tar.gz
RUN tar xvzf /tmp/hugo_bin.tar.gz -C /tmp
RUN cp /tmp/hugo /bin/hugo
RUN rm /tmp/* -r

WORKDIR hugo
COPY hugo .
RUN hugo




