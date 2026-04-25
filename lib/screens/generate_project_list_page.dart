import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

class GenerateProjectListPage extends StatefulWidget {
  @override
  _GenerateProjectListPageState createState() => _GenerateProjectListPageState();
}

class _GenerateProjectListPageState extends State<GenerateProjectListPage> {

  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  void fetchProjects() async {
    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/project/all"),
      );

      print("STATUS: ${res.statusCode}");
      print("BODY: ${res.body}");

      if (res.statusCode == 200) {
        setState(() {
          data = jsonDecode(res.body);
        });
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
      appBar: AppBar(title: Text("Project List")),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? Center(child: Text("No Data Found"))
          : Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              border: TableBorder.all(),

              columns: const [
                DataColumn(label: Text("Sr.No")),
                DataColumn(label: Text("Client ID")),
                DataColumn(label: Text("Client Name")),
                DataColumn(label: Text("Location")),
                DataColumn(label: Text("Project Name")),
                DataColumn(label: Text("NH Code")),
                DataColumn(label: Text("Project Package")),
              ],

              rows: List.generate(data.length, (i) {
                var d = data[i];

                return DataRow(cells: [
                  DataCell(Text("${i + 1}")),
                  DataCell(Text(d["clientId"]?.toString() ?? "")),
                  DataCell(Text(d["clientName"] ?? "")),
                  DataCell(Text(d["location"] ?? "")),
                  DataCell(Text(d["projectName"] ?? "")),
                  DataCell(Text(d["projectCode"] ?? "")), // NH CODE
                  DataCell(Text(d["projectPackage"] ?? "")),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}