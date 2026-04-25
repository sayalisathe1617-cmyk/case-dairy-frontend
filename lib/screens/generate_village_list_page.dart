import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GenerateVillageListPage extends StatefulWidget {
  @override
  _VillageListPageState createState() => _VillageListPageState();
}

class _VillageListPageState extends State<GenerateVillageListPage> {

  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  void fetch() async {
    try {
      print("API CALL START");

      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/location/all"),
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
      appBar: AppBar(title: Text("Village List")),

      body: loading
          ? Center(child: CircularProgressIndicator())
          : data.isEmpty
          ? Center(child: Text("No Data Found"))
          : Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              border: TableBorder.all(color: Colors.black),

              columns: const [
                DataColumn(label: Text("Sr.No")),
                DataColumn(label: Text("Village")),
                DataColumn(label: Text("District")),
                DataColumn(label: Text("Taluka")),
              ],

              rows: List.generate(data.length, (i) {
                var d = data[i];

                return DataRow(cells: [
                  DataCell(Text("${i + 1}")),
                  DataCell(Text(d["village"] ?? "")),
                  DataCell(Text(d["district"] ?? "")),
                  DataCell(Text(d["taluka"] ?? "")),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}