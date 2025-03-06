# ---------- Stage 1: Build DeepLX main service ----------
    FROM golang:1.18-alpine AS builder_main
    WORKDIR /src
    # 复制整个项目（确保 go.mod, go.sum 以及源码文件都在内）
    COPY . .
    # 下载依赖并构建 DeepLX 可执行文件
    RUN go mod download
    RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -a -installsuffix cgo -o deeplx .
    
    # ---------- Stage 2: Build Proxy service ----------
    FROM golang:1.18-alpine AS builder_proxy
    WORKDIR /proxy
    # 仅复制 proxy 目录内容
    COPY proxy/ .
    RUN go mod tidy
    RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -a -o deeplx_proxy .
    
    # ---------- Stage 3: Final image ----------
    FROM alpine:latest
    WORKDIR /app
    
    # 复制 DeepLX main service binary
    COPY --from=builder_main /src/deeplx .
    # 复制 proxy service binary
    COPY --from=builder_proxy /proxy/deeplx_proxy .
    
    # 安装 supervisord
    RUN apk add --no-cache supervisor
    
    # 暴露端口：1188 用于 DeepLX 服务，1199 用于代理服务
    EXPOSE 1188
    EXPOSE 1199
    
    # 创建 supervisord 配置文件
    RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisord.conf && \
        echo "[program:deeplx]\ncommand=/app/deeplx\n" >> /etc/supervisord.conf && \
        echo "[program:proxy]\ncommand=/app/deeplx_proxy\n" >> /etc/supervisord.conf
    
    # 设置启动命令
    CMD ["supervisord", "-c", "/etc/supervisord.conf"]
    