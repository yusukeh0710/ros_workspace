FROM python:3.12

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get install -y \
    bash \
    ca-certificates \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    jupyterlab \
    rosdep

WORKDIR /workspace
COPY entrypoint.sh /workspace/entrypoint.sh
RUN chmod +x /workspace/entrypoint.sh
EXPOSE 8888

ENTRYPOINT ["./entrypoint.sh"]
