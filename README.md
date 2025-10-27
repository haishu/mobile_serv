# Mobile File Server

A simple yet powerful file server application built with Flutter. It allows you to host files from your device and access them through a web browser on any other device within the same local network.

---

## English

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

*   `shelf` & `shelf_router`: 用于服务器后端。
*   `webview_flutter`: 用于应用内浏览器。
*   `path_provider`: 用于访问设备的文件存储。

**Setup:**

```bash
# Clone the repository
git clone <repository-url>
cd flutter_web

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## English

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
git clone <repository-url>
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
