// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late File jsonFile;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    String embPath = tempDir.path + '/emb.json';
    jsonFile = File(embPath);

    if (jsonFile.existsSync()) {
      setState(() {
        data = json.decode(jsonFile.readAsStringSync());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            String key = data.keys.elementAt(index);
            return ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${index + 1}. $key"),
                  ElevatedButton(
                    onPressed: () {
                      String nameToRemove = key;
                      data.remove(nameToRemove);
                      jsonFile.writeAsStringSync(json.encode(data));
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.delete),
                  )
                ],
              ),
            );
          }),
    );
  }
}
