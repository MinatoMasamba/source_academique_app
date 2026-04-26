import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

enum DownloadStatus { idle, downloading, complete, error }

class DownloadProgressButton extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final VoidCallback? onDownloadComplete;
  final VoidCallback? onError;

  const DownloadProgressButton({
    super.key,
    required this.fileUrl,
    required this.fileName,
    this.onDownloadComplete,
    this.onError,
  });

  @override
  State<DownloadProgressButton> createState() => _DownloadProgressButtonState();
}

class _DownloadProgressButtonState extends State<DownloadProgressButton> {
  DownloadStatus _status = DownloadStatus.idle;
  double _progress = 0.0;
  String? _errorMessage;
  CancelToken? _cancelToken;

  // Variables pour la taille réelle
  int _receivedBytes = 0;
  int _totalBytes = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = switch (_status) {
      DownloadStatus.idle => const Text(
          "TÉLÉCHARGER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      DownloadStatus.downloading => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: _progress > 0 ? _progress : null,
                strokeWidth: 2,
                color: Colors.white,
                backgroundColor: Colors.white30,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                _formatProgressText(),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      DownloadStatus.complete => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                "TÉLÉCHARGÉ",
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      DownloadStatus.error => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _errorMessage ?? "ERREUR",
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
    };

    return ElevatedButton(
      onPressed: _status == DownloadStatus.downloading ? null : _startDownload,
      style: ElevatedButton.styleFrom(
        backgroundColor: _status == DownloadStatus.complete
            ? Colors.green
            : (_status == DownloadStatus.error ? Colors.red : theme.colorScheme.primary),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: child,
    );
  }

  /// Formate le texte de progression (ex: "1.2 MB / 5.4 MB")
  String _formatProgressText() {
    if (_totalBytes <= 0) {
      // Si on ne connaît pas la taille totale, afficher seulement la taille reçue
      return _formatBytes(_receivedBytes);
    }

    final received = _formatBytes(_receivedBytes);
    final total = _formatBytes(_totalBytes);
    final percent = (_progress * 100).toInt();

    return "$received / $total ($percent%)";
  }

  /// Convertit des octets en format lisible (B, KB, MB, GB)
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    } else if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else {
      return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _status = DownloadStatus.downloading;
      _progress = 0.0;
      _errorMessage = null;
      _receivedBytes = 0;
      _totalBytes = 0;
    });

    _cancelToken = CancelToken();

    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ));

      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/${widget.fileName}';

      await dio.download(
        widget.fileUrl,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (mounted) {
            setState(() {
              _receivedBytes = received;
              _totalBytes = total;
              _progress = total > 0 ? received / total : 0.0;
            });
          }
        },
      );

      setState(() => _status = DownloadStatus.complete);
      widget.onDownloadComplete?.call();
      _showOpenFileDialog(savePath);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        setState(() => _status = DownloadStatus.idle);
        return;
      }
      setState(() {
        _status = DownloadStatus.error;
        _errorMessage = _getErrorMessage(e);
      });
      widget.onError?.call();
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai dépassé';
      case DioExceptionType.badResponse:
        return 'Erreur serveur (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Annulé';
      default:
        return 'Échec du téléchargement';
    }
  }

  void _showOpenFileDialog(String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force l'utilisateur à choisir
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          // --- STYLE DE LA BOÎTE ---
          backgroundColor: theme.brightness == Brightness.dark 
              ? Colors.grey[900] // Fond sombre solide
              : Colors.white,    // Fond blanc pur
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2), width: 1),
          ),
          elevation: 24,

          // --- CONTENU ---
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              const Text('Succès'),
            ],
          ),
          content: const Text(
            'Le document a été téléchargé avec succès. Souhaitez-vous l\'ouvrir maintenant ?',
            style: TextStyle(fontSize: 16),
          ),

          // --- ACTIONS ---
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'PLUS TARD',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                OpenFile.open(filePath);
              },
              child: const Text('OUVRIR LE FICHIER'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}