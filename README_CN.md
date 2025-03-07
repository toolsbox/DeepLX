# DeepLX with Proxy

DeepLX-with-Proxy 是 DeepLX 的增强版，集成了一个轻量级代理服务，能够将 HTTP GET 请求转换为 HTTP POST 请求，使得只支持 GET 请求的应用（如 PotPlayer）也能无缝调用 DeepLX 翻译 API。

## 功能特点

- **DeepLX 翻译服务**：提供高质量的翻译能力。
- **GET 转 POST 代理**：将 HTTP GET 请求转换为 POST 请求，使其兼容仅支持 GET 请求的应用。
- **Docker 支持**：可通过 Docker 轻松部署，内置 DeepLX 和 Proxy 服务。
- **Supervisord 进程管理**：确保两个服务在容器中稳定运行。

## 安装与使用

### 使用 Docker 运行

```sh
docker run -d --name deeplx-with-proxy -p 1188:1188 -p 1199:1199 xtoolsbox/deeplx-with-proxy
```

- DeepLX 翻译服务运行在 **1188 端口**。
- 代理服务运行在 **1199 端口**。

### 使用示例

#### 直接调用 DeepLX API（POST 请求）

```sh
curl -X POST "http://localhost:1188/translate" -H "Content-Type: application/json" -d '{"text": "Hello", "target_lang": "ZH"}'
```

#### 通过代理 API（GET 请求）

```sh
curl "http://localhost:1199/translate?text=Hello&target_lang=ZH"
```

## 从源码构建和运行

### 依赖环境

- Go 1.24+
- Docker（可选，适用于容器化部署）

### 克隆代码仓库

```sh
git clone https://github.com/your-username/DeepLX-with-Proxy.git
cd DeepLX-with-Proxy
```

### 本地运行

```sh
cd proxy
go run main.go
```

## 开源协议

本项目基于 MIT 许可证，详细信息请参阅 [LICENSE](LICENSE) 文件。

## 致谢

本项目基于 [DeepLX](https://github.com/OwO-Network/DeepLX) 开发，感谢原始开发者的贡献。

