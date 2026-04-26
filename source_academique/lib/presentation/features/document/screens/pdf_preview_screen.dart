import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfPreviewScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfPreviewScreen({super.key, required this.title, required this.pdfUrl});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late PdfController _pdfController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPdfController();
  }

  void _initPdfController() {
    _pdfController = PdfController(
      document: PdfDocument.openData(_downloadPdfData()),
    );
  }

  Future<Uint8List> _downloadPdfData() async {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
      ));
      final response = await dio.get<List<int>>(
        widget.pdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        setState(() => _isLoading = false);
        return Uint8List.fromList(response.data!);
      } else {
        throw Exception('Code HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Erreur réseau';
      if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Problème de connexion (CORS ?)';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'Fichier introuvable';
      }
      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
      rethrow;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur inattendue : $e';
      });
      rethrow;
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _pdfController.dispose();
    _initPdfController();
  }

  void _openInBrowser() async {
    final uri = Uri.parse(widget.pdfUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retry,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Impossible de charger le document',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Ouvrir dans le navigateur'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfView(
      controller: _pdfController,
      onDocumentLoaded: (_) => setState(() => _isLoading = false),
      onDocumentError: (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      },
      builders: PdfViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        pageLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorBuilder: (_, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur : $error'),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _openInBrowser,
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Ouvrir dans le navigateur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }
}