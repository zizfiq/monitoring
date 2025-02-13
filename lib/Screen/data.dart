import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:monitoring/Widget/snackbar.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<FeedingData> feedingData = [];
  final String apiKey = 'AIzaSyC9kIkLAGkB0xIS31vXQ8mtqMXED9TnSQc';
  final String databaseUrl =
      'https://monitoring-2f6fc-default-rtdb.asia-southeast1.firebasedatabase.app';

  @override
  void initState() {
    super.initState();
    _fetchFeedingData();
  }

  Future<void> _fetchFeedingData() async {
    final response =
        await http.get(Uri.parse('$databaseUrl/feedingData.json?auth=$apiKey'));
    if (response.statusCode == 200 && response.body != 'null') {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        feedingData = data.entries.map((entry) {
          final value = entry.value;
          return FeedingData(
            timestamp: DateTime.parse(value['timestamp']),
            feedAmount: value['feedAmount'],
            temperature: value['temperature'],
            tds: value['tds'],
            ph: value['ph'],
          );
        }).toList();
        feedingData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    }
  }

  Future<void> _deleteAllData() async {
    final response = await http
        .delete(Uri.parse('$databaseUrl/feedingData.json?auth=$apiKey'));
    if (response.statusCode == 200) {
      setState(() {
        feedingData.clear();
      });
      showSnackBar(context, 'Data berhasil dihapus');
    } else {
      print('Failed to delete data');
    }
  }

  Future<void> _exportDataToCSV() async {
    if (feedingData.isEmpty) {
      showSnackBar(context, 'Tidak ada data untuk diekspor');
      return;
    }

    String csvData = 'Tanggal,Berat Pakan,Suhu,TDS,pH\n';
    for (var data in feedingData) {
      csvData +=
          '${DateFormat('dd/MM/yyyy HH:mm').format(data.timestamp)},${data.feedAmount},${data.temperature},${data.tds},${data.ph}\n';
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/Data_Tambak_udang.csv';
    final file = File(path);
    await file.writeAsString(csvData);

    Share.shareXFiles([XFile(path)], text: 'Data Pakan');

    showSnackBar(context, 'Data telah diekspor ke CSV');
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Pakan',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload, color: Colors.green),
            onPressed: () {
              _exportDataToCSV(); // Memanggil fungsi ekspor data ke CSV
              Navigator.pop(context); // Kembali ke layar sebelumnya
            },
            tooltip: 'Ekspor Data ke CSV',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Hapus Semua Data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  content: const Text(
                    'Apakah Anda yakin ingin menghapus semua data?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.black, width: 2),
                  ),
                  backgroundColor: Colors.white,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteAllData();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Hapus Semua Data',
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Tanggal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Berat\nPakan',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Suhu',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'TDS',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'pH',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: feedingData.length,
                itemBuilder: (context, index) {
                  final data = feedingData[index];
                  final isEven = index.isEven;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isEven ? Colors.white : Colors.grey[50],
                      border: const Border(
                        bottom: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(_formatDateTime(data.timestamp)),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              '${data.feedAmount}g',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${data.temperature.toStringAsFixed(0)}°C',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${data.tds.toStringAsFixed(0)}ppm',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            data.ph.toStringAsFixed(3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedingData {
  final DateTime timestamp;
  final int feedAmount;
  final double temperature;
  final double tds;
  final double ph;

  FeedingData({
    required this.timestamp,
    required this.feedAmount,
    required this.temperature,
    required this.tds,
    required this.ph,
  });
}
