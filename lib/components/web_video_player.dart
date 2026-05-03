import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as webview;

@NowaGenerated()
class WebVideoPlayer extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const WebVideoPlayer({
    required this.url,
    this.userAgent,
    this.referer,
    super.key,
  });

  final String url;

  final String? userAgent;

  final String? referer;

  @override
  State<WebVideoPlayer> createState() {
    return _WebVideoPlayerState();
  }
}

@NowaGenerated()
class _WebVideoPlayerState extends State<WebVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    final String effectiveUserAgent =
        widget.userAgent ??
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
    final Map<String, String> headers = {};
    final String? referer = widget.referer;
    if (referer != null && referer!.isNotEmpty) {
      headers['Referer'] = referer;
    }
    final String autoPlayScript =
        '      (function() {\n        function forcePlay() {\n          var videos = document.getElementsByTagName(\'video\');\n          for (var i = 0; i < videos.length; i++) {\n            if (videos[i].paused) {\n              videos[i].play().catch(function(error) {\n                console.log("Autoplay prevent: ", error);\n              });\n            }\n          }\n        }\n        setInterval(forcePlay, 1000);\n      })();\n    ';
    return webview.InAppWebView(
      initialUrlRequest: webview.URLRequest(
        url: webview.WebUri(widget.url),
        headers: headers,
      ),
      initialSettings: webview.InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        userAgent: effectiveUserAgent,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        supportZoom: false,
        transparentBackground: true,
      ),
      onLoadStop: (controller, url) async {
        await controller.evaluateJavascript(source: autoPlayScript);
      },
    );
  }
}
