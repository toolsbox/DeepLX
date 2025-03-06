# 使用官方的 Python 镜像作为基础镜像
FROM python:3.11-slim AS proxy_builder

# 设置工作目录
WORKDIR /app

# 将代理服务器脚本复制到容器中
COPY deeplx_proxy.py .

# 安装代理服务器所需的依赖
RUN pip install flask requests

# 使用官方的 Go 镜像作为构建器
FROM golang:1.20-alpine AS builder

# 设置工作目录
WORKDIR /go/src/github.com/OwO-Network/DeepLX

# 将项目文件复制到构建器中
COPY . .

RUN apk update && apk add --no-cache build-base

# 下载依赖并构建可执行文件
RUN go mod download
RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -a -installsuffix cgo -o deeplx .

# 使用一个精简的基础镜像
FROM alpine:latest

# 设置工作目录
WORKDIR /app

# 从构建器复制构建的可执行文件
COPY --from=builder /go/src/github.com/OwO-Network/DeepLX/deeplx .

# 从代理服务器构建器复制代理服务器脚本和依赖
COPY --from=proxy_builder /app/deeplx_proxy.py .
COPY --from=proxy_builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=proxy_builder /usr/local/bin/flask /usr/local/bin/flask
COPY --from=proxy_builder /usr/local/bin/python3 /usr/local/bin/python3

# 暴露端口 1188（DeepLX 服务）和 1199（代理服务）
EXPOSE 1188
EXPOSE 1199

# 使用 supervisord 来管理多个服务
RUN apk add --no-cache supervisor

# 创建 supervisord 配置文件
RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisord.conf \
    && echo "[program:deeplx]\ncommand=/app/deeplx\n" >> /etc/supervisord.conf \
    && echo "[program:proxy]\ncommand=python3 /app/deeplx_proxy.py\n" >> /etc/supervisord.conf

# 设置容器启动时运行 supervisord
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
