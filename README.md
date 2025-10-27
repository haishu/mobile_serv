# Mobile File Server

A simple yet powerful file server application built with Flutter. It allows you to host files from your device and access them through a web browser on any other device within the same local network.

---

## English (Main)

### Features

*   **Local HTTP Server**: Start and stop an HTTP server directly from your phone.
*   **IP Address Detection**: Automatically lists available local IPv4 addresses for easy setup. You can also bind the server to all available interfaces (`0.0.0.0`).
*   **Web Interface**: A clean, responsive web UI for file management, accessible from any browser.
    *   **List Files**: View all available files.
    *   **File Upload**: Upload files with a progress bar. Supports large files through chunking and parallel uploads. Also features drag-and-drop support.
    *   **File Deletion**: Securely delete files from the server.
    *   **In-Browser Video Player**: Stream videos directly in the browser. The player automatically detects and loads corresponding subtitle files (e.g., `.vtt`, `.en.vtt`).
*   **Range Request Support**: Efficiently streams large files, especially videos.
*   **In-App Browser**: Preview the server's web interface directly within the app.
*   **Clipboard Integration**: Easily copy server URLs to the clipboard.

### How to Use

1.  **Start the App**: Launch the application on your device.
2.  **Select IP and Port**:
    *   The app will display a list of available IP addresses on your network.
    *   Choose an IP address. Selecting `All addresses` (`0.0.0.0`) makes the server accessible via any of your phone's local IPs.
    *   You can change the default port if needed.
3.  **Start the Server**: Tap the "Start Server" button.
4.  **Access from another device**:
    *   The app will display one or more URLs.
    *   On another device (like a laptop or tablet) connected to the **same Wi-Fi network**, open a web browser and navigate to one of these URLs.
5.  **Manage Files**: You can now use the web interface to upload, download, view, and delete files.

### For Developers

This project is built with Flutter and uses the following key packages:

*   `shelf` & `shelf_router` for the server backend.
*   `webview_flutter` for the in-app browser.
*   `path_provider` to access the device's file storage.

**Setup:**

```bash
# Clone the repository
git clone <your-repository-url>
cd flutter_web

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Svenska (Swedish)

### Funktioner

*   **Lokal HTTP-server**: Starta och stoppa en HTTP-server direkt från din telefon.
*   **IP-adressavkänning**: Listar automatiskt tillgängliga lokala IPv4-adresser för enkel konfiguration. Du kan också binda servern till alla tillgängliga nätverkskort (`0.0.0.0`).
*   **Webbgränssnitt**: Ett rent och responsivt webbgränssnitt för filhantering, tillgängligt från vilken webbläsare som helst.
    *   **Lista filer**: Se alla tillgängliga filer.
    *   **Filuppladdning**: Ladda upp filer med en förloppsindikator. Stödjer stora filer genom uppdelning (chunking) och parallella uppladdningar. Har även stöd för dra-och-släpp.
    *   **Ta bort filer**: Radera filer säkert från servern.
    *   **Inbyggd videospelare**: Strömma video direkt i webbläsaren. Spelaren hittar och läser automatiskt in matchande undertextfiler (t.ex. `.vtt`, `.en.vtt`).
*   **Stöd för Range Requests**: Möjliggör effektiv strömning av stora filer, särskilt video.
*   **Inbyggd webbläsare**: Förhandsgranska serverns webbgränssnitt direkt i appen.
*   **Urklippsintegration**: Kopiera enkelt serverns URL:er till urklipp.

### Hur du använder appen

1.  **Starta appen**: Öppna applikationen på din enhet.
2.  **Välj IP och port**:
    *   Appen visar en lista över tillgängliga IP-adresser på ditt nätverk.
    *   Välj en IP-adress. Om du väljer `Alla adresser` (`0.0.0.0`) blir servern nåbar via alla telefonens lokala IP-adresser.
    *   Du kan ändra standardporten om det behövs.
3.  **Starta servern**: Tryck på knappen "Starta service".
4.  **Anslut från en annan enhet**:
    *   Appen kommer att visa en eller flera URL:er.
    *   Öppna en webbläsare på en annan enhet (t.ex. en dator eller surfplatta) som är ansluten till **samma Wi-Fi-nätverk** och gå till en av dessa URL:er.
5.  **Hantera filer**: Du kan nu använda webbgränssnittet för att ladda upp, ladda ner, visa och ta bort filer.

### För utvecklare

Detta projekt är byggt med Flutter och använder följande viktiga paket:

*   `shelf` & `shelf_router` för server-backend.
*   `webview_flutter` för den inbyggda webbläsaren.
*   `path_provider` för att komma åt enhetens fillagring.

**Installation:**

```bash
# Klona repot
git clone <your-repository-url>
cd flutter_web

# Installera beroenden
flutter pub get

# Kör appen
flutter run
```

---

## 简体中文 (Simplified Chinese)

### 功能特性

*   **本地 HTTP 服务器**: 直接从您的手机启动和停止一个 HTTP 服务器。
*   **IP 地址检测**: 自动列出可用的本地 IPv4 地址，方便快速设置。您也可以将服务器绑定到所有可用网络接口 (`0.0.0.0`)。
*   **Web 界面**: 一个简洁、响应式的 Web UI，可从任何浏览器访问以进行文件管理。
    *   **文件列表**: 查看所有可用的文件。
    *   **文件上传**: 支持带进度条的文件上传。通过分块和并行上传技术，支持大文件。同时支持拖放上传。
    *   **文件删除**: 从服务器安全地删除文件。
    *   **浏览器内视频播放器**: 直接在浏览器中流式播放视频。播放器会自动检测并加载相应的字幕文件（例如 `.vtt`, `.en.vtt`）。
*   **范围请求 (Range Request) 支持**: 高效地流式传输大文件，尤其是视频。
*   **应用内浏览器**: 直接在 App 内部预览服务器的 Web 界面。
*   **剪贴板集成**: 轻松将服务器 URL 复制到剪贴板。

### 如何使用

1.  **启动应用**: 在您的设备上打开本应用。
2.  **选择 IP 和端口**:
    *   应用会显示您网络中的可用 IP 地址列表。
    *   选择一个 IP 地址。选择 `所有地址` (`0.0.0.0`) 会使服务器可以通过您手机的所有本地 IP 访问。
    *   如果需要，您可以更改默认端口。
3.  **启动服务器**: 点击“启动服务”按钮。
4.  **从其他设备访问**:
    *   应用将显示一个或多个 URL。
    *   在另一台连接到**相同 Wi-Fi 网络**的设备（如笔记本电脑或平板电脑）上，打开网页浏览器并访问其中一个 URL。
5.  **管理文件**: 现在您可以使用 Web 界面来上传、下载、查看和删除文件。

### 开发者指南

本项目使用 Flutter 构建，并依赖以下关键包：

*   `shelf` & `shelf_router`: 用于服务器后端。
*   `webview_flutter`: 用于应用内浏览器。
*   `path_provider`: 用于访问设备的文件存储。

**安装与运行:**

```bash
# 克隆仓库
git clone <your-repository-url>
cd flutter_web

# 安装依赖
flutter pub get

# 运行应用
flutter run
```
