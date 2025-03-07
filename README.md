[![Chinese](https://img.shields.io/badge/lang-中文-blue.svg)](README_CN.md)

# DeepLX with Proxy

DeepLX-with-Proxy is an enhanced version of DeepLX, integrating a lightweight proxy service that enables HTTP GET requests to be converted into HTTP POST requests. This allows applications that only support GET requests, such as PotPlayer, to use the DeepLX translation API seamlessly.

## Features
- **DeepLX Translation Service**: Provides high-quality translation capabilities.
- **Proxy for GET-to-POST Conversion**: Converts HTTP GET requests into POST requests, making it compatible with applications that require GET requests.
- **Docker Support**: Easily deploy using Docker with integrated DeepLX and Proxy services.
- **Supervisord Process Management**: Ensures stable operation of both services within the container.

## Installation & Usage

### Running with Docker
```sh
docker run -d --name deeplx-with-proxy -p 1188:1188 -p 1199:1199 xtoolsbox/deeplx-with-proxy
```
- The DeepLX translation service runs on port **1188**.
- The proxy service runs on port **1199**.

### Example Usage
#### Directly Using DeepLX API (POST Request)
```sh
curl -X POST "http://localhost:1188/translate" -H "Content-Type: application/json" -d '{"text": "Hello", "target_lang": "ZH"}'
```

#### Using the Proxy API (GET Request)
```sh
curl "http://localhost:1199/translate?text=Hello&target_lang=ZH"
```

## Build & Run from Source

### Prerequisites
- Go 1.24+
- Docker (optional for containerized deployment)

### Clone the Repository
```sh
git clone https://github.com/your-username/DeepLX-with-Proxy.git
cd DeepLX-with-Proxy
```

### Run Locally
```sh
cd proxy
go run main.go
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements
This project is based on [DeepLX](https://github.com/OwO-Network/DeepLX). Thanks to the original developers for their contributions.

