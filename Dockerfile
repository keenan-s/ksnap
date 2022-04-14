FROM alpine/curl AS build

WORKDIR /workdir

RUN set -ex \
    && curl -L -o azcopy.tar.gz \
    https://aka.ms/downloadazcopy-v10-linux \
    && tar -xf azcopy.tar.gz --strip-components=1 \
    && rm -f azcopy.tar.gz

FROM python:3.10.4-alpine

# Create an app user so our program doesn't run as root.
RUN mkdir -p /home/ksnap
RUN addgroup -S ksnap && adduser -S ksnap -G ksnap

# make sure completion is loaded
RUN echo "source /etc/bash_completion" > /home/ksnap/.bashrc
RUN echo "source /etc/bash_completion.d/ksnap " >> /home/ksnap/.bashrc

RUN apk add --no-cache git gcc musl-dev librdkafka librdkafka-dev

# Add azcopy
COPY --from=build /workdir/azcopy /usr/local/bin

# Install ksnap
COPY ksnap /code
RUN pip install /code

RUN chown -R ksnap:ksnap /home/ksnap

USER ksnap
CMD ["ksnap"]