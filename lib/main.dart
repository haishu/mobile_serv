import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于复制到剪贴板
import 'server.dart';
import 'webview_page.dart'; // 你自己的 WebView 页面
import 'package:logging/logging.dart';

final _logger = Logger('MyServer');


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 文件服务器',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> ipList = [];
  String? selectedIp;
  int port = 8080;
  SimpleHttpServer? server;
  String? serverUrl;
  bool running = false;
  final TextEditingController portController =
      TextEditingController(text: '8080');

  @override
  void initState() {
    super.initState();
    _getIPs();
  }

  Future<void> _getIPs() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );

    List<String> ips = [];
    for (var iface in interfaces) {
      for (var addr in iface.addresses) {
        ips.add(addr.address);
      }
    }

    if (!mounted) return;

    setState(() {
      ipList = ['0.0.0.0'] + ips;
      if (selectedIp != null && ipList.contains(selectedIp)) {
        // 保留原选中
      } else {
        selectedIp = ipList.isNotEmpty ? ipList.first : null;
      }
    });
  }

  Future<void> startServer(String ip) async {
    final inputPort = int.tryParse(portController.text);
    if (inputPort == null || inputPort < 1025 || inputPort > 65535) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入合法端口号: 1025~65535'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    server = SimpleHttpServer();
    int tryPort = inputPort;
    bool started = false;

    while (!started && tryPort <= 65535) {
      try {
        await server!.start(ip, tryPort);
        started = true;
        port = tryPort;
      } catch (e) {
        tryPort++;
        if (tryPort > 65535 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('无法找到可用端口，启动失败'), duration: Duration(seconds: 1)),
          );
        }
      }
    }

    if (!mounted) return;
    setState(() {
      if (ip == '0.0.0.0') {
        serverUrl = null; // 多地址模式
      } else {
        serverUrl = 'http://$ip:$port';
      }
      running = true;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('服务器已启动: ${serverUrl ?? "所有地址"}'),
          duration: Duration(seconds: 1)),
    );
  }

  Future<void> stopServer() async {
    if (server != null) {
      try {
        await server!.stop();
      } catch (e, stackTrace) {
        _logger.severe('Server stop error', e, stackTrace);
      } finally {
        // 这里只做同步清理
        server = null;
      }

      // 下面的异步操作移到 try/catch/finally 之外
      if (!mounted) return;

      setState(() {
        running = false;
        serverUrl = null;
      });

      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;

      await _getIPs();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('服务器已停止'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void openWebView(String url) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WebViewPage(url: url)),
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
    );
  }

  @override
  void dispose() {
    server?.stop();
    portController.dispose();
    super.dispose();
  }

  bool get canStart =>
      selectedIp != null && int.tryParse(portController.text) != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 文件服务器')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('选择手机可用 IP 地址启动服务:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _getIPs, // 下拉刷新 IP 列表
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    if (!running) ...[
                      // ================= 未启动服务 =================
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: portController,
                          decoration: const InputDecoration(
                            labelText: '端口号',
                            hintText: '例如 8080（1025~65535）',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // IP 列表或下拉提示
                      if (ipList.isEmpty)
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.arrow_downward,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  '未检测到可用 IP\n下拉刷新试试',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...ipList.map((ip) {
                          final displayText = ip == '0.0.0.0' ? '所有地址' : ip;
                          return ListTile(
                            leading: const Icon(Icons.wifi),
                            title: Text(displayText,
                                style: const TextStyle(color: Colors.blue)),
                            trailing: selectedIp == ip
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () => setState(() => selectedIp = ip),
                          );
                        }),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed:
                              canStart ? () => startServer(selectedIp!) : null,
                          child: const Text('启动服务'),
                        ),
                      ),
                    ] else ...[
                      // ================= 已启动服务 =================
                      const Text('服务器已启动:', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),

                      // 单地址模式
                      if (serverUrl != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => openWebView(serverUrl!),
                                child: Text(
                                  serverUrl!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () => copyToClipboard(serverUrl!),
                            ),
                          ],
                        ),
                      ]
                      // 多地址模式
                      else ...[
                        ...ipList.where((ip) => ip != '0.0.0.0').map((ip) {
                          final url = 'http://$ip:$port';
                          return Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => openWebView(url),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: Text(
                                      url,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                onPressed: () => copyToClipboard(url),
                              ),
                            ],
                          );
                        }),
                      ],

                      // ✅ 停止服务按钮作为列表最后一项
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: stopServer,
                          child: const Text('停止服务'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
