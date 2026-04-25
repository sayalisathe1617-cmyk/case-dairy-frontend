import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'generate_arbitration_case_list_page.dart';

class ArbitrationCaseDetailsPage extends StatefulWidget {
  final String title;
  ArbitrationCaseDetailsPage({this.title = "Arbitration Case Details"});

  @override
  _ArbitrationCaseDetailsPageState createState() =>
      _ArbitrationCaseDetailsPageState();
}

class _ArbitrationCaseDetailsPageState
    extends State<ArbitrationCaseDetailsPage> {

  final double labelWidth = 150;
  final double gap = 12;
  final double fieldHeight = 38;
  final double commonWidth = 300;

  final clientId = TextEditingController();
  final clientName = TextEditingController();
  final location = TextEditingController();

  final village = TextEditingController();
  final district = TextEditingController();
  final taluka = TextEditingController();

  List<String> districtList = [];
  List<String> talukaList = [];

  String? selectedDistrict;
  String? selectedTaluka;

  final nhCode = TextEditingController();
  final projectName = TextEditingController();
  String? projectPackage;

  final caseNo = TextEditingController();
  final year = TextEditingController();

  final otherClaim = TextEditingController();
  final claimRs = TextEditingController();
  final rate = TextEditingController();
  final amount = TextEditingController();

  final respAdv = TextEditingController();
  final appAdv = TextEditingController();

  bool hasStructure = false;
  final structureDetails = TextEditingController();

  bool hasTrees = false;
  final treeDetails = TextEditingController();

  List<TextEditingController> applicants = [TextEditingController()];
  List<TextEditingController> respondents = [TextEditingController()];

  final docName = TextEditingController();
  final docDate = TextEditingController();
  List<Map<String, String>> docs = [];

  void addRow(List<TextEditingController> list) {
    setState(() => list.add(TextEditingController()));
  }

  void saveCase() async {
    if (clientId.text.isEmpty ||
        caseNo.text.isEmpty ||
        year.text.isEmpty ||
        nhCode.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    if (int.tryParse(year.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Year must be number")),
      );
      return;
    }

    try {
      var res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/arbitration/save"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "clientId": int.tryParse(clientId.text),
          "clientName": clientName.text,
          "location": location.text,
          "village": village.text,
          "district": district.text,
          "taluka": taluka.text,
          "nhCode": nhCode.text,
          "projectName": projectName.text,
          "projectPackage": projectPackage,
          "caseNo": caseNo.text,
          "year": int.tryParse(year.text),
          "applicant": applicants.map((e) => e.text).join(","),
          "respondent": respondents.map((e) => e.text).join(","),
          "hasStructure": hasStructure,
          "structureDetails": structureDetails.text,
          "hasTrees": hasTrees,
          "treeDetails": treeDetails.text,
          "otherClaim": otherClaim.text,
          "claimRs": double.tryParse(claimRs.text),
          "rate": double.tryParse(rate.text),
          "amount": double.tryParse(amount.text),
          "respAdv": respAdv.text,
          "appAdv": appAdv.text,
        }),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saved Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save Failed")),
        );
      }

    } catch (e) {
      print("ERROR: $e");
    }
  }

  void fetchClient(String id) async {

    if (id.isEmpty) {
      clientName.clear();
      location.clear();
      return;
    }

    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/client/$id"),
      );

      if (res.statusCode == 200 && res.body != "null") {
        var data = jsonDecode(res.body);

        setState(() {
          clientName.text = data["name"] ?? "";
          location.text = data["location"] ?? "";
        });
      } else {
        clientName.clear();
        location.clear();
      }

    } catch (e) {
      print("ERROR: $e");
    }
  }

// 🔥 ADD HERE (after saveCase)
  void fetchLocation(String villageName) async {

    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/location/byVillage/$villageName"),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        setState(() {
          districtList =
              data.map<String>((e) => e["district"]?.toString() ?? "").toSet().toList();

          talukaList =
              data.map<String>((e) => e["taluka"]?.toString() ?? "").toSet().toList();
          // 🔥 AUTO SELECT FIRST VALUE
          if (districtList.isNotEmpty) {
            selectedDistrict = districtList[0];
            district.text = selectedDistrict!;
          }

          if (talukaList.isNotEmpty) {
            selectedTaluka = talukaList[0];
            taluka.text = selectedTaluka!;
          }
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  List projectList = []; // 🔥 ADD ABOVE (top variables)

  void fetchProject(String code) async {

    if (code.isEmpty) {
      projectList = [];
      projectName.clear();
      projectPackage = null;
      return;
    }

    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/project/byCode/$code"),
      );

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);

        setState(() {
          projectList = data;
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

// 🔹 CLIENT
            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Client ID")),
                SizedBox(
                  width: 80,
                  height: fieldHeight,
                  child: TextField(
                    controller: clientId,
                    keyboardType: TextInputType.number,
                    onChanged: fetchClient, // 🔥 AUTO FETCH
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: gap),

                SizedBox(width: labelWidth, child: Text("Client Name")),
                box(clientName, 200),

                SizedBox(width: gap),

                SizedBox(width: labelWidth, child: Text("Location")),
                box(location, 200),
              ],
            ),

            SizedBox(height: gap),
// Village
            Row(
              children: [

                // 🔹 VILLAGE
                SizedBox(width: labelWidth, child: Text("Village")),
                SizedBox(
                  width: 200,
                  height: fieldHeight,
                  child: TextField(
                    controller: village,
                    onChanged: (val) {
                      if (val.length > 2) {
                        fetchLocation(val); // 🔥 AUTO FETCH
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(width: gap),

                // 🔹 DISTRICT
                SizedBox(width: labelWidth, child: Text("District")),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    items: districtList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDistrict = val;
                        district.text = val ?? "";
                      });
                    },
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),

                SizedBox(width: gap),

                // 🔹 TALUKA
                SizedBox(width: labelWidth, child: Text("Taluka")),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    value: selectedTaluka,
                    items: talukaList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedTaluka = val;
                        taluka.text = val ?? "";
                      });
                    },
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
// 🔹 PROJECT
            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("NH Code")),
                SizedBox(
                  width: 100,
                  height: fieldHeight,
                  child: TextField(
                    controller: nhCode,
                    onChanged: fetchProject, // 🔥 AUTO FETCH
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),

                SizedBox(width: gap),

                SizedBox(width: labelWidth, child: Text("Project Name")),
                SizedBox(
                  width: commonWidth,
                  child: DropdownButtonFormField(
                    value: projectName.text.isEmpty ? null : projectName.text,
                    items: projectList.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem(
                        value: p["projectName"],
                        child: Text(p["projectName"]),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        projectName.text = val ?? "";
                      });
                    },
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),

                SizedBox(width: gap),

                SizedBox(width: labelWidth, child: Text("Project Package")),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField(
                    value: projectPackage,
                    items: projectList.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem(
                        value: p["projectPackage"],
                        child: Text(p["projectPackage"]),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        projectPackage = val;
                      });
                    },
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            SizedBox(height: gap),
            Divider(),

// 🔹 CASE
            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Case No")),
                box(caseNo, 120),

                SizedBox(width: gap),

                SizedBox(width: labelWidth, child: Text("Year")),
                box(year, 80, isNumber: true),
              ],
            ),

            SizedBox(height: gap),

// 🔹 MULTI INPUT
            buildMulti("Applicant Name", applicants),
            buildMulti("Respondent Name", respondents),

            SizedBox(height: gap),

// 🔹 STRUCTURE
            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Structure")),
                Radio(
                    value: true,
                    groupValue: hasStructure,
                    onChanged: (v) => setState(() => hasStructure = true)),
                Text("Yes"),
                Radio(
                    value: false,
                    groupValue: hasStructure,
                    onChanged: (v) => setState(() => hasStructure = false)),
                Text("No"),
              ],
            ),
            if (hasStructure)
              row("Details", structureDetails, commonWidth),

// 🔹 TREES
            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Trees")),
                Radio(
                    value: true,
                    groupValue: hasTrees,
                    onChanged: (v) => setState(() => hasTrees = true)),
                Text("Yes"),
                Radio(
                    value: false,
                    groupValue: hasTrees,
                    onChanged: (v) => setState(() => hasTrees = false)),
                Text("No"),
              ],
            ),
            if (hasTrees)
              row("Details", treeDetails, commonWidth),

            SizedBox(height: gap),

// 🔹 OTHER CLAIM
            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Other Claim")),
                SizedBox(
                  width: commonWidth,
                  child: TextField(
                    controller: otherClaim,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "min 500 characters",
                      counterText: "",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: gap),

            row("Applicant Claim Rs", claimRs, 120),
            row("Rate Awarded", rate, 120),
            row("Amount Awarded", amount, 120),

            row("Respondent Adv Name", respAdv, commonWidth),
            row("Applicant Adv Name", appAdv, commonWidth),

            SizedBox(height: gap),

// 🔥 DOCUMENTS INLINE
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: labelWidth, child: Text("Documents")),

                Container(
                  width: 260,
                  constraints: BoxConstraints(minHeight: 80, maxHeight: 100),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: docs.asMap().entries.map((e) {
                        return Text(
                          "${e.key + 1}. ${e.value["name"]}   ${e.value["date"]}",
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(width: 10),

                Text("Document Name"),
                SizedBox(width: 5),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: docName,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.attach_file),
                      isDense: true,
                    ),
                  ),
                ),

                SizedBox(width: 10),

                Text("Document Date"),
                SizedBox(width: 5),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: docDate,
                    maxLength: 10,
                    decoration: InputDecoration(
                      hintText: "dd/mm/yyyy",
                      counterText: "",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),

                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    if (docName.text.isEmpty || docDate.text.isEmpty) return;

                    setState(() {
                      docs.add({
                        "name": docName.text,
                        "date": docDate.text,
                      });
                    });

                    docName.clear();
                    docDate.clear();
                  },
                  child: Text("Upload"),
                ),
              ],
            ),

            SizedBox(height: 20),

            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  btn("Save", saveCase),
                  btn("Edit", () {}),
                  btn("Delete", () {}),
                  btn("Close", () => Navigator.pop(context)),
                ],
              ),
            ),
            SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 450, // 🔥 SAME TOTAL WIDTH
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // 🔥 Navigate to list page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GenerateArbitrationCaseListPage(),
                        ),
                      );
                    },
                    child: Text("Generate Arbitration Case List"),
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }


  Widget box(TextEditingController c, double w, {bool isNumber = false}) {
    return SizedBox(
      width: w,
      height: fieldHeight,
      child: TextField(
        controller: c,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
        isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration:
        InputDecoration(border: OutlineInputBorder(), isDense: true),
      ),
    );
  }

  Widget row(String label, TextEditingController c, double w) {
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: Row(
        children: [
          SizedBox(width: labelWidth, child: Text(label)),
          box(c, w),
        ],
      ),
    );
  }

  Widget buildMulti(String label, List<TextEditingController> list) {
    return Column(
      children: list.asMap().entries.map((e) {
        bool last = e.key == list.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: gap),
          child: Row(
            children: [
              SizedBox(
                width: labelWidth,
                child: e.key == 0 ? Text(label) : SizedBox(),
              ),
              box(e.value, commonWidth),
              if (last)
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => addRow(list),
                )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget btn(String text, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: SizedBox(
        width: 100,
        height: 38,
        child: OutlinedButton(
          onPressed: onTap,
          child: Text(text),
        ),
      ),
    );
  }
}
