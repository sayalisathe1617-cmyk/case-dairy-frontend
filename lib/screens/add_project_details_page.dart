import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'generate_project_list_page.dart';

class AddProjectPage extends StatefulWidget {
  @override
  _AddProjectPageState createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {

  final clientId = TextEditingController();
  final clientName = TextEditingController();
  final location = TextEditingController();

  final projectName = TextEditingController();
  final projectCode = TextEditingController();

  String? selectedPackage;

  void fetchProjectByName(String name) async {

    if (name.isEmpty || name.length < 3) {
      projectCode.clear();
      selectedPackage = null;
      return;
    }

    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/project/byName/$name"),
      );

      if (res.statusCode == 200 && res.body != "null") {
        var data = jsonDecode(res.body);

        setState(() {
          projectCode.text = data["projectCode"] ?? "";
          selectedPackage = data["projectPackage"];
        });
      } else {
        projectCode.clear();
        selectedPackage = null;
      }

    } catch (e) {
      print("ERROR: $e");
    }
  }

  // 🔥 AUTO FETCH CLIENT
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
      print("ERROR FETCH: $e");
    }
  }

  // 🔥 FINAL SAVE (WITH VALIDATION)
  void saveProject() async {

    // 🔴 VALIDATION
    if (clientId.text.isEmpty ||
        int.tryParse(clientId.text) == null ||
        projectName.text.isEmpty ||
        projectCode.text.isEmpty ||
        selectedPackage == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      var url = Uri.parse("${ApiConfig.baseUrl}/project/save");
      print("API URL: $url");
      var data = {
        "clientId": int.tryParse(clientId.text),
        "projectName": projectName.text,
        "projectCode": projectCode.text,
        "projectPackage": selectedPackage,
      };

      print("SENDING DATA: $data");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saved Successfully")),
        );
        clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save Failed")),
        );
      }

    } catch (e) {
      print("ERROR SAVE: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server Error")),
      );
    }
  }

  void clearForm() {
    clientId.clear();
    clientName.clear();
    location.clear();
    projectName.clear();
    projectCode.clear();
    selectedPackage = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Project Details")),

      body: Center(
        child: Container(
          width: 750,
          padding: EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text("Add Project Details",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  Divider(),

                  // 🔥 CLIENT ID → AUTO FILL
                  Row(
                    children: [

                      SizedBox(width: 120, child: Text("Client ID")),

                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: clientId,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: fetchClient,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), isDense: true),
                        ),
                      ),

                      SizedBox(width: 20),

                      SizedBox(width: 100, child: Text("Client Name")),

                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: clientName,
                          readOnly: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), isDense: true),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  row("Location", location, 200, readOnly: true),

                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 120, child: Text("Project Name")),
                        SizedBox(
                          width: 250,
                          height: 38,
                          child: TextField(
                            controller: projectName,
                            onChanged: (val) {
                              if (val.length > 2) {
                                fetchProjectByName(val); // 🔥 AUTO FETCH
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  row("NH Code", projectCode, 120),

                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 120, child: Text("Project Package")),
                        SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            value: selectedPackage,
                            hint: Text("Select"),
                            items: ["pkg I", "pkg II", "pkg III"]
                                .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedPackage = val;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        actionBtn("Save", saveProject),
                        SizedBox(width: 10),
                        actionBtn("Edit", () {}),
                        SizedBox(width: 10),
                        actionBtn("Delete", () {}),
                        SizedBox(width: 10),
                        actionBtn("Cancel", clearForm),
                      ],
                    ), // ✅ comma IMPORTANT

                    SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 410, // 🔥 SAME AS 4 BUTTONS WIDTH
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GenerateProjectListPage(),
                              ),
                            );
                          },
                          child: Text("Generate Village List"), // 👈 text change if needed
                        ),

                      ),
                      ],
                    ),

                  ], // ✅ THIS closes children list
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget row(String label, TextEditingController c, double width,
      {bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          SizedBox(
            width: width,
            height: 38,
            child: TextField(
              controller: c,
              readOnly: readOnly,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionBtn(String text, VoidCallback onTap) {
    return SizedBox(
      width: 95,
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
}