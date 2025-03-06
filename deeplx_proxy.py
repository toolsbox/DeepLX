#!/usr/bin/env python3
# This python script make the DeepLX support HTTP GET method. So Potplayer can use DeepLX api to translate subtiles.

from flask import Flask, request, jsonify, Response
import requests

app = Flask(__name__)

# 请根据实际情况修改 deeplx 服务地址
DEEPLX_URL = "http://127.0.0.1:1188/translate"

@app.route("/translate", methods=["GET"])
def proxy_translate():
    # 从 GET 参数中获取翻译内容和目标语言
    text = request.args.get("text", "")
    target_lang = request.args.get("target_lang", "")
    source_lang = request.args.get("source_lang", None)

    if not text or not target_lang:
        return jsonify({"error": "Missing text or target_lang parameter"}), 400

    # 构造 JSON 请求体
    payload = {"text": text, "target_lang": target_lang}
    if source_lang:
        payload["source_lang"] = source_lang

    headers = {"Content-Type": "application/json"}
    
    try:
        # 向 deeplx 服务发送 POST 请求
        resp = requests.post(DEEPLX_URL, json=payload, headers=headers, timeout=10)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    # 将 deeplx 返回的响应原样返回给客户端
    response = Response(resp.content, status=resp.status_code, content_type=resp.headers.get("Content-Type", "application/json"))
    return response

if __name__ == "__main__":
    # 监听本地 0.0.0.0:1199 端口
    app.run(host="0.0.0.0", port=1199)
