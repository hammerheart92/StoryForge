// lib/screens/debug_screen.dart
// Debug screen to diagnose environment configuration issues

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/api_config.dart';
import '../services/narrative_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final NarrativeService _service = NarrativeService();
  String? _statusResult;
  bool _isChecking = false;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
      _statusResult = null;
    });

    try {
      final isAvailable = await _service.checkStatus();
      setState(() {
        _statusResult = isAvailable
            ? 'SUCCESS: Backend is reachable'
            : 'FAILED: Backend returned non-200 status';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _statusResult = 'ERROR: $e';
        _isChecking = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environment Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection(
              'Environment Variables',
              [
                _buildInfoRow('ENV (from dart-define)', ApiConfig.environment),
                _buildInfoRow('Is Production?', ApiConfig.isProduction.toString()),
                _buildInfoRow('Is Development?', ApiConfig.isDevelopment.toString()),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'API Configuration',
              [
                _buildInfoRow('Base URL', ApiConfig.baseUrl, copyable: true),
                _buildInfoRow('Production URL', ApiConfig.productionNarrativeUrl, copyable: true),
                _buildInfoRow('Development URL', ApiConfig.developmentNarrativeUrl, copyable: true),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Backend Status Check',
              [
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkStatus,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.network_check),
                  label: Text(_isChecking ? 'Checking...' : 'Test Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                if (_statusResult != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusResult!.startsWith('SUCCESS')
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      border: Border.all(
                        color: _statusResult!.startsWith('SUCCESS')
                            ? Colors.green
                            : Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusResult!.startsWith('SUCCESS')
                              ? Icons.check_circle
                              : Icons.error,
                          color: _statusResult!.startsWith('SUCCESS')
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusResult!,
                            style: TextStyle(
                              color: _statusResult!.startsWith('SUCCESS')
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Instructions',
              [
                const Text(
                  'To run in production mode:\n'
                  '1. Close the app completely\n'
                  '2. Run: flutter run --dart-define=ENV=production\n'
                  '3. Or use: run_prod.bat\n\n'
                  'To run in development mode:\n'
                  '1. Close the app completely\n'
                  '2. Run: flutter run\n'
                  '3. (development is the default)',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () => _copyToClipboard(value),
              tooltip: 'Copy',
            ),
        ],
      ),
    );
  }
}
