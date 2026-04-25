import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

class ClientListPage extends StatefulWidget {
  const ClientListPage({super.key});

  @override
  _ClientListPageState createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {

  List clients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  // 🔥 UPDATED FUNCTION
  void fetchClients() async {
    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/client/all"),
      );
      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");
      if (res.statusCode == 200) {
        setState(() {
          clients = jsonDecode(res.body);
        });
      } else {
        print("ERROR STATUS: ${res.statusCode}");
      }
    } catch (e) {
      print("ERROR: $e");
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client List")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : clients.isEmpty
          ? const Center(child: Text("No Data Found"))
          : Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              border: TableBorder.all(color: Colors.black),

              columns: const [
                DataColumn(label: Text("Sr.No")),
                DataColumn(label: Text("Client ID")),
                DataColumn(label: Text("Client Name")),
                DataColumn(label: Text("Address")),
                DataColumn(label: Text("Location")),
                DataColumn(label: Text("Contact Name")),
                DataColumn(label: Text("Contact No")),
                DataColumn(label: Text("Email")),
              ],

              rows: List.generate(clients.length, (index) {
                var c = clients[index];

                return DataRow(cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(c['id']?.toString() ?? "")),
                  DataCell(Text(c['name'] ?? "")),
                  DataCell(Text(c['address'] ?? "")),
                  DataCell(Text(c['location'] ?? "")),
                  DataCell(Text(c['contactName'] ?? "")),
                  DataCell(Text(c['contactNumber'] ?? "")),
                  DataCell(Text(c['email'] ?? "")),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}