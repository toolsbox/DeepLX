package main

import (
    "encoding/json"
    "io/ioutil"
    "log"
    "net/http"
    "time"
	"bytes"
)

// DeepLX 服务地址（原服务，监听在 1188 端口）
const deeplxURL = "http://127.0.0.1:1188/translate"

// 翻译请求结构体（可选，仅用于记录数据）
type translateRequest struct {
    Text       string `json:"text"`
    TargetLang string `json:"target_lang"`
    SourceLang string `json:"source_lang,omitempty"`
}

func proxyTranslate(w http.ResponseWriter, r *http.Request) {
    // 从 GET 参数中获取
    text := r.URL.Query().Get("text")
    targetLang := r.URL.Query().Get("target_lang")
    sourceLang := r.URL.Query().Get("source_lang")

    if text == "" || targetLang == "" {
        http.Error(w, `{"error": "Missing text or target_lang parameter"}`, http.StatusBadRequest)
        return
    }

    // 构造请求数据
    payload := translateRequest{
        Text:       text,
        TargetLang: targetLang,
        SourceLang: sourceLang,
    }

    jsonData, err := json.Marshal(payload)
    if err != nil {
        http.Error(w, `{"error": "Failed to marshal JSON"}`, http.StatusInternalServerError)
        return
    }

    client := &http.Client{Timeout: 10 * time.Second}
    req, err := http.NewRequest("POST", deeplxURL, ioutil.NopCloser(bytes.NewReader(jsonData)))
    if err != nil {
        http.Error(w, `{"error": "`+err.Error()+`"}`, http.StatusInternalServerError)
        return
    }
    req.Header.Set("Content-Type", "application/json")

    resp, err := client.Do(req)
    if err != nil {
        http.Error(w, `{"error": "`+err.Error()+`"}`, http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        http.Error(w, `{"error": "Failed to read response from DeepLX service"}`, http.StatusInternalServerError)
        return
    }

    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(resp.StatusCode)
    w.Write(body)
}

func main() {
    http.HandleFunc("/translate", proxyTranslate)
    log.Println("Proxy server is running on port 1199...")
    log.Fatal(http.ListenAndServe(":1199", nil))
}
