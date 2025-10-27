import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:mime/mime.dart';

class SimpleHttpServer {
  HttpServer? _server;
  Directory? _appDir;

  Future<String> start([String host = '0.0.0.0', int port = 8080]) async {
    _appDir = await getExternalStorageDirectory();
    if (_appDir == null) throw Exception('无法获取存储目录');

    final router = Router();

    // ---------- 首页 ----------
    router.get('/', (Request request) {
      final files = _appDir!
          .listSync()
          .whereType<File>()
          .where((f) => !f.uri.pathSegments.last.startsWith('res_timestamp-'))
          .toList();

      final fileListHtml = files.map((f) {
        final name = f.uri.pathSegments.last;
        final encodedName = Uri.encodeComponent(name);
        final mimeType = lookupMimeType(f.path) ?? 'application/octet-stream';

        String icon;
        if (mimeType.startsWith('video/')) {
          icon = '🎬';
        } else if (mimeType.startsWith('image/')) icon = '🖼️';
        else if (mimeType.startsWith('text/') || mimeType == 'application/pdf') icon = '📄';
        else icon = '📦';

        final actionLink = mimeType.startsWith('video/')
            ? "javascript:playVideo('$encodedName')"
            : '/$encodedName';

        return '''
<li class="list-group-item d-flex justify-content-between align-items-center flex-wrap">
  <span>
    <span style="margin-right:0.5rem;">$icon</span>
    <a href="$actionLink">$name</a>
  </span>
  <form method="POST" action="/delete" onsubmit="return confirm('确定删除 $name 吗？');">
    <input type="hidden" name="file" value="$encodedName">
    <button class="btn btn-sm btn-danger">删除</button>
  </form>
</li>
''';
      }).join('');

      final html = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>文件上传/下载</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
body { padding: 1rem; }
h2 { margin-top: 2rem; }
.file-list { max-width: 100%; margin-top: 1rem; }
#video-container { margin-top: 2rem; max-width: 100%; }
video { width: 100%; height: auto; display:none; }
</style>
</head>
<body>
<div class="container">

<h2>上传文件</h2>
<form id="upload-form" class="mb-4">
  <div class="mb-3">
    <input type="file" name="file" id="file-input" class="d-none" required>
    <button type="button" class="btn btn-primary w-100 mb-2" onclick="document.getElementById('file-input').click()">选择文件</button>
    <div id="drop-zone" class="form-control text-muted text-center" style="padding: 30px; border: 2px dashed #ccc; cursor: pointer;">
      将文件拖到此处，或点击上方按钮选择<br>
      <span id="file-name">未选择文件</span>
    </div>
  </div>
  <button type="submit" class="btn btn-success w-100">上传</button>
  <div class="progress mt-3" style="height: 25px; display: none;">
    <div id="progress-bar" class="progress-bar progress-bar-striped progress-bar-animated"
         role="progressbar" style="width: 0%">0%</div>
  </div>
</form>

<h2>已上传文件</h2>
<ul class="list-group file-list">
$fileListHtml
</ul>

<div id="video-container">
  <video id="video" width="640" controls></video>
</div>

<script>
// ---------- JS 上传逻辑 ----------
const input = document.getElementById('file-input');
const nameSpan = document.getElementById('file-name');
const dropZone = document.getElementById('drop-zone');
const form = document.getElementById('upload-form');
const progressContainer = document.querySelector('.progress');
const progressBar = document.getElementById('progress-bar');

input.addEventListener('change', () => {
  nameSpan.textContent = input.files[0]?.name || '未选择文件';
});

dropZone.addEventListener('dragover', (e) => { e.preventDefault(); dropZone.style.borderColor='blue'; dropZone.style.color='blue'; });
dropZone.addEventListener('dragleave', () => { dropZone.style.borderColor='#ccc'; dropZone.style.color='#6c757d'; });
dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  dropZone.style.borderColor='#ccc';
  dropZone.style.color='#6c757d';
  if (e.dataTransfer.files.length > 0) {
    input.files = e.dataTransfer.files;
    nameSpan.textContent = input.files[0].name;
  }
});

async function uploadFileInChunksParallel(file) {
  const chunkSize = 10 * 1024 * 1024;
  const totalChunks = Math.ceil(file.size / chunkSize);
  const maxParallel = 4;
  const maxRetry = 3;

  progressContainer.style.display = 'block';
  progressBar.style.width = '0%';
  progressBar.textContent = '0%';

  const chunks = [];
  for (let i = 0; i < totalChunks; i++) {
    chunks.push({ index: i, blob: file.slice(i * chunkSize, (i + 1) * chunkSize) });
  }

  const chunkProgress = Array(totalChunks).fill(0);

  function updateOverallProgress() {
    const totalProgress = Math.floor(chunkProgress.reduce((a, b) => a + b, 0) / totalChunks);
    progressBar.style.width = totalProgress + '%';
    progressBar.textContent = totalProgress < 100 ? totalProgress + '%' : '上传完成';
  }

  async function uploadChunkJS(chunkObj, attempt = 1) {
    try {
      const formData = new FormData();
      formData.append('file', chunkObj.blob, file.name);
      formData.append('chunkIndex', chunkObj.index);
      formData.append('totalChunks', totalChunks);
      formData.append('fileSize', file.size);

      await new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        xhr.open('POST', '/upload_chunk', true);

        xhr.upload.onprogress = (event) => {
          if (event.lengthComputable) {
            chunkProgress[chunkObj.index] = Math.round((event.loaded / event.total) * 100);
            updateOverallProgress();
          }
        };

        xhr.onload = () => {
          if (xhr.status >= 200 && xhr.status < 300) {
            chunkProgress[chunkObj.index] = 100;
            updateOverallProgress();
            resolve();
          } else reject(new Error('上传失败'));
        };

        xhr.onerror = () => reject(new Error('网络错误'));
        xhr.send(formData);
      });

    } catch (err) {
      if (attempt < maxRetry) {
        console.warn(`分块上传失败，重试...`);
        await uploadChunkJS(chunkObj, attempt + 1);
      } else throw new Error(`分块上传失败`);
    }
  }

  const queue = [];
  while (chunks.length > 0) {
    while (queue.length < maxParallel && chunks.length > 0) {
      const chunkObj = chunks.shift();
      const promise = uploadChunkJS(chunkObj);
      queue.push(promise);
      promise.finally(() => queue.splice(queue.indexOf(promise), 1));
    }
    await Promise.race(queue);
  }

  await Promise.all(queue);
  setTimeout(() => { progressContainer.style.display = 'none'; window.location.reload(); }, 1000);
}

form.addEventListener('submit', (e) => {
  e.preventDefault();
  if (input.files.length === 0) { alert('请先选择文件'); return; }
  const file = input.files[0];
  uploadFileInChunksParallel(file);
});

// ---------- 视频播放 ----------
document.addEventListener('DOMContentLoaded', () => {
  const video = document.getElementById('video');

  window.playVideo = (encodedFileName) => {
    const decodedName = decodeURIComponent(encodedFileName);
    const url = '/' + decodedName;

    video.src = url;
    video.style.display = 'block';
    video.scrollIntoView({ behavior: 'smooth' });

    // ---------- 添加字幕 ----------
    Array.from(video.querySelectorAll('track')).forEach(t => t.remove());
    const baseName = decodedName.replace(/\\.[^/.]+\$/, '');
    const captions = [
      { lang: 'zh', file: baseName + '.zh.vtt', label: '中文' },
      { lang: 'en', file: baseName + '.en.vtt', label: 'English' },
      { lang: '',  file: baseName + '.vtt',    label: 'Default' }
    ];

    captions.forEach(c => {
      fetch('/' + encodeURIComponent(c.file), { method: 'HEAD' })
        .then(res => {
          if (res.ok) {
            const track = document.createElement('track');
            track.src = '/' + encodeURIComponent(c.file);
            track.kind = 'subtitles';
            track.label = c.label;
            if (c.lang) track.srclang = c.lang;
            track.default = false;
            video.appendChild(track);
          }
        })
        .catch(() => {});
    });

    const goFullscreen = () => {
      if (video.requestFullscreen) video.requestFullscreen();
      else if (video.webkitRequestFullscreen) video.webkitRequestFullscreen();
      else if (video.msRequestFullscreen) video.msRequestFullscreen();
    };
    goFullscreen();

    video.play().catch(e => console.error('播放失败', e));

    const cleanup = () => {
      video.pause();
      video.removeAttribute('src');
      video.load();
      video.style.display = 'none';
      document.removeEventListener('fullscreenchange', onFullScreenExit);
      document.removeEventListener('webkitfullscreenchange', onFullScreenExit);
      document.removeEventListener('msfullscreenchange', onFullScreenExit);
      video.removeEventListener('ended', cleanup);
    };

    video.addEventListener('ended', cleanup);

    const onFullScreenExit = () => {
      if (!document.fullscreenElement &&
          !document.webkitFullscreenElement &&
          !document.msFullscreenElement) {
        cleanup();
      }
    };

    document.addEventListener('fullscreenchange', onFullScreenExit);
    document.addEventListener('webkitfullscreenchange', onFullScreenExit);
    document.addEventListener('msfullscreenchange', onFullScreenExit);
  };
});
</script>

</div>
</body>
</html>
''';

      return Response.ok(html, headers: {'Content-Type': 'text/html'});
    });

    // ---------- 后端分块上传 ----------
    router.post('/upload_chunk', (Request request) async {
      try {
        final multipart = request.multipart();
        if (multipart == null) return Response(400, body: '无效上传请求');

        String? filename;
        int? chunkIndex;
        int? totalChunks;
        int? expectedFileSize;
        List<int>? fileBytes;

        await for (final part in multipart.parts) {
          final disposition = part.headers['content-disposition'] ?? '';
          final fieldNameMatch = RegExp(r'name="(.+?)"').firstMatch(disposition);
          if (fieldNameMatch == null) continue;
          final fieldName = fieldNameMatch.group(1)!;

          if (fieldName == 'file') {
            final filenameMatch = RegExp(r'filename="(.+?)"').firstMatch(disposition);
            filename = filenameMatch?.group(1);
            fileBytes = await part.expand((chunk) => chunk).toList();
          } else {
            final valueBytes = await part.expand((chunk) => chunk).toList();
            final value = String.fromCharCodes(valueBytes);
            if (fieldName == 'chunkIndex') chunkIndex = int.tryParse(value);
            if (fieldName == 'totalChunks') totalChunks = int.tryParse(value);
            if (fieldName == 'fileSize') expectedFileSize = int.tryParse(value);
          }
        }

        if (filename == null || fileBytes == null || chunkIndex == null || totalChunks == null) {
          return Response(400, body: '缺少必要上传参数');
        }

        final safeFilename = p.basename(filename);
        final chunkDir = Directory(p.join(_appDir!.path, '$safeFilename.chunks'));
        if (!await chunkDir.exists()) await chunkDir.create(recursive: true);

        final chunkFile = File(p.join(chunkDir.path, '$chunkIndex.chunk'));
        await chunkFile.writeAsBytes(fileBytes, flush: true);

        // 合并
        bool allReady = true;
        for (int i = 0; i < totalChunks; i++) {
          if (!await File(p.join(chunkDir.path, '$i.chunk')).exists()) {
            allReady = false;
            break;
          }
        }

        if (allReady) {
          final finalFile = File(p.join(_appDir!.path, safeFilename));
          final sink = finalFile.openWrite();
          for (int i = 0; i < totalChunks; i++) {
            final receivedChunkFile = File(p.join(chunkDir.path, '$i.chunk'));
            await sink.addStream(receivedChunkFile.openRead());
            await receivedChunkFile.delete();
          }
          await sink.flush();
          await sink.close();
          await chunkDir.delete();

          if (expectedFileSize != null) {
            final actualSize = await finalFile.length();
            if (actualSize != expectedFileSize) {
              await finalFile.delete();
              return Response(500, body: '合并后文件大小不匹配，上传失败');
            }
          }
        }

        return Response.ok('分块上传成功');
      } catch (e, st) {
        print('上传错误: $e\n$st');
        return Response(500, body: '上传失败: $e');
      }
    });

    // ---------- 删除 ----------
    router.post('/delete', (Request request) async {
      final params = await request.readAsString();
      final uri = Uri(query: params);
      final fileParam = uri.queryParameters['file'];
      if (fileParam == null) return Response(400, body: '缺少文件名');

      final safePath = p.normalize(p.join(_appDir!.path, Uri.decodeComponent(fileParam)));
      final target = File(safePath);
      if (!safePath.startsWith(_appDir!.path)) return Response(403, body: '非法操作');
      if (!target.existsSync()) return Response(404, body: '文件未找到');

      try {
        await target.delete();
        return Response.ok('<script>window.location.href="/";</script>',
            headers: {'Content-Type': 'text/html; charset=utf-8'});
      } catch (e) {
        return Response(500,
            body: '<script>alert("删除失败: $e");history.back();</script>',
            headers: {'Content-Type': 'text/html; charset=utf-8'});
      }
    });

    // ---------- 文件访问（Range 支持） ----------
    router.get('/<filename|.*>', (Request request, String filename) async {
      final decodedName = Uri.decodeComponent(filename);
      final safePath = p.normalize(p.join(_appDir!.path, decodedName));
      if (!safePath.startsWith(_appDir!.path)) return Response(403, body: '非法文件访问');

      final file = File(safePath);
      if (!file.existsSync()) return Response.notFound('文件未找到');

      final fileLength = await file.length();
      final rangeHeader = request.headers['range'];

      final firstBytes = await file.openRead(0, 64).fold<List<int>>([], (p, e) => p..addAll(e));
      final mimeType = lookupMimeType(file.path, headerBytes: firstBytes) ?? 'application/octet-stream';

      final contentDisposition = mimeType.startsWith('video/') ||
              mimeType.startsWith('image/') ||
              mimeType.startsWith('text/') ||
              mimeType == 'application/pdf'
          ? 'inline'
          : 'attachment';

      if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
        try {
          final parts = rangeHeader.substring(6).split('-');
          final start = int.parse(parts[0]);
          final end = parts[1].isNotEmpty ? int.parse(parts[1]) : fileLength - 1;
          if (start >= fileLength || end >= fileLength || start > end) {
            return Response(HttpStatus.requestedRangeNotSatisfiable,
                headers: {'Content-Range': 'bytes */$fileLength'});
          }
          final length = end - start + 1;
          final stream = file.openRead(start, end + 1);
          return Response(HttpStatus.partialContent,
              body: stream,
              headers: {
                'Content-Type': mimeType,
                'Content-Range': 'bytes $start-$end/$fileLength',
                'Content-Length': length.toString(),
                'Accept-Ranges': 'bytes',
                'Content-Disposition':
                    '$contentDisposition; filename*=UTF-8\'\'${Uri.encodeComponent(decodedName)}',
              });
        } catch (_) {
          return Response(HttpStatus.requestedRangeNotSatisfiable,
              headers: {'Content-Range': 'bytes */$fileLength'});
        }
      }

      return Response.ok(file.openRead(), headers: {
        'Content-Type': mimeType,
        'Content-Length': fileLength.toString(),
        'Accept-Ranges': 'bytes',
        'Content-Disposition':
            '$contentDisposition; filename*=UTF-8\'\'${Uri.encodeComponent(decodedName)}',
      });
    });

    _server = await shelf_io.serve(router.call, InternetAddress(host), port);
    return 'http://${_server!.address.address}:$port';
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
