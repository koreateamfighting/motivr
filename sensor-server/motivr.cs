using System;
using System.Collections;
using System.Text;
using UnityEngine;
using NativeWebSocket;
using UnityEngine.Networking;
using UnityEngine.UI;

public class ReceiveApi : MonoBehaviour
{
    WebSocket websocket;
    public Text debugTextClient;
    public Text debugTextServer;

    private bool isClosing = false;

    async void Awake()
    {
        websocket = new WebSocket("wss://hanlimtwin.kr:3030");

        websocket.OnOpen += () =>
        {
            Debug.Log("WebSocket 연결 성공!");
            SafeSetText(debugTextClient, "WebSocket 연결 성공!");
        };

        websocket.OnError += (e) =>
        {
            Debug.LogError("WebSocket 오류: " + e);
            SafeSetText(debugTextClient, "오류: " + e);
        };

        websocket.OnClose += (e) =>
        {
            Debug.Log("WebSocket 연결 해제됨");
            SafeSetText(debugTextClient, "연결 해제됨");
        };

        websocket.OnMessage += (bytes) =>
        {
            if (isClosing) return;

            var msg = Encoding.UTF8.GetString(bytes);
            Debug.Log("📩 수신한 원본 메시지: " + msg); 

            try
            {
                FullMessageWrapper wrapper = JsonUtility.FromJson<FullMessageWrapper>(msg);
                Debug.Log(">>> 파싱 성공");

                if (wrapper != null && wrapper.receivedData != null)
                {
                    if (wrapper.source == "server")
                    {
                        SafeSetText(debugTextServer, $"[서버 전송]\nID: {wrapper.receivedData.ID}\n값: {wrapper.receivedData.val}");
                        //SafeSetText(debugTextServer, "서버에서 메시지를 받았습니다.");

                    }
                    else
                    {
                        SafeSetText(debugTextClient, $"[클라이언트 전송]\nID: {wrapper.receivedData.ID}\n값: {wrapper.receivedData.val}");
                    }
                }
                else
                {
                    Debug.LogWarning("wrapper 또는 receivedData null");
                }
            }
            catch (Exception ex)
            {
                Debug.LogWarning("JSON 파싱 실패: " + ex.Message);
            }
        };

        await websocket.Connect();
    }

    void Update()
    {
#if !UNITY_WEBGL || UNITY_EDITOR
        websocket?.DispatchMessageQueue();
#endif
    }

    private async void OnDestroy()
    {
        isClosing = true;
        if (websocket != null)
        {
            await websocket.Close();
            websocket = null;
        }
    }

    public void OnSendJsonButtonClick()
    {
        StartCoroutine(SendJsonData());
    }

    IEnumerator SendJsonData()
    {
        string url = "https://hanlimtwin.kr:3030/api/test_submit_data";
        string jsonData = "{\"ID\":\"변위센서\", \"val\":0.3}";

        UnityWebRequest request = new UnityWebRequest(url, "POST");
        byte[] bodyRaw = Encoding.UTF8.GetBytes(jsonData);
        request.uploadHandler = new UploadHandlerRaw(bodyRaw);
        request.downloadHandler = new DownloadHandlerBuffer();
        request.SetRequestHeader("Content-Type", "application/json");

        yield return request.SendWebRequest();

        if (request.result == UnityWebRequest.Result.Success)
        {
            Debug.Log("응답 받음: " + request.downloadHandler.text);
            try
            {
                FullMessageWrapper wrapper = JsonUtility.FromJson<FullMessageWrapper>(request.downloadHandler.text);
                SafeSetText(debugTextClient, $"[전송 성공 응답]\nID: {wrapper.receivedData.ID}\n값: {wrapper.receivedData.val}");
            }
            catch (Exception ex)
            {
                Debug.LogWarning("JSON 파싱 실패: " + ex.Message);
                SafeSetText(debugTextClient, "전송 성공 (파싱 실패)");
            }
        }
        else
        {
            Debug.LogError("에러 발생: " + request.error);
            SafeSetText(debugTextClient, "에러: " + request.error);
        }
    }

    void SafeSetText(Text target, string message)
    {
        if (target != null)
        {
            target.text = message;
        }
    }
}

[Serializable]
public class FullMessageWrapper
{
    public string source;
    public ServerResponse receivedData;
}

[Serializable]
public class ServerResponse
{
    public string ID;
    public float val;
}
