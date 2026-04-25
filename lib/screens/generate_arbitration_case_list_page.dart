import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class GenerateArbitrationCaseListPage extends StatefulWidget {
  @override
  _GenerateArbitrationCaseListPageState createState() =>
      _GenerateArbitrationCaseListPageState();
}

class _GenerateArbitrationCaseListPageState
    extends State<GenerateArbitrationCaseListPage> {

  List data = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCases();
  }

  void fetchCases() async {
    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/arbitration/all"),
      );

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

  String yesNo(bool? val) {
    if (val == true) return "Yes";
    return "No";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Arbitration Case List")),

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
                DataColumn(label: Text("Client Name")),
                DataColumn(label: Text("Location")),
                DataColumn(label: Text("Village")),
                DataColumn(label: Text("District")),
                DataColumn(label: Text("Taluka")),
                DataColumn(label: Text("NH Code")),
                DataColumn(label: Text("Project Name")),
                DataColumn(label: Text("Package Name")),
                DataColumn(label: Text("Case No")),
                DataColumn(label: Text("Year")),
                DataColumn(label: Text("Structure")),
                DataColumn(label: Text("Trees")),
                DataColumn(label: Text("Other Claim")),
                DataColumn(label: Text("Applicant Claim Rs")),
                DataColumn(label: Text("Rate Awarded")),
                DataColumn(label: Text("Amount Awarded")),
                DataColumn(label: Text("Respondent Adv")),
                DataColumn(label: Text("Applicant Adv")),
                DataColumn(label: Text("Documents")),
                DataColumn(label: Text("Doc Name")),
                DataColumn(label: Text("Doc Date")),
              ],

              rows: List.generate(data.length, (i) {
                var d = data[i];

                return DataRow(cells: [
                  DataCell(Text("${i + 1}")),
                  DataCell(Text(d["clientName"] ?? "")),
                  DataCell(Text(d["location"] ?? "")),
                  DataCell(Text(d["village"] ?? "")),
                  DataCell(Text(d["district"] ?? "")),
                  DataCell(Text(d["taluka"] ?? "")),
                  DataCell(Text(d["nhCode"] ?? "")),
                  DataCell(Text(d["projectName"] ?? "")),
                  DataCell(Text(d["projectPackage"] ?? "")),
                  DataCell(Text(d["caseNo"] ?? "")),
                  DataCell(Text(d["year"]?.toString() ?? "")),
                  DataCell(Text(yesNo(d["hasStructure"]))),
                  DataCell(Text(yesNo(d["hasTrees"]))),
                  DataCell(Text(d["otherClaim"] ?? "")),
                  DataCell(Text(d["claimRs"]?.toString() ?? "")),
                  DataCell(Text(d["rate"]?.toString() ?? "")),
                  DataCell(Text(d["amount"]?.toString() ?? "")),
                  DataCell(Text(d["respAdv"] ?? "")),
                  DataCell(Text(d["appAdv"] ?? "")),
                  DataCell(Text("View")), // optional
                  DataCell(Text("")), // future use
                  DataCell(Text("")), // future use
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}