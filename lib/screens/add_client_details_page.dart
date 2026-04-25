import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'generate_client_list.dart'; // ✅ KEEP (ClientListPage इथे असेल तर)

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  _AddClientPageState createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {

  final clientId = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final location = TextEditingController();
  final contactName = TextEditingController();
  final contactNo = TextEditingController();
  final email = TextEditingController();

  bool sameAsClient = false;
  String message = "";

  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    getNextId();
  }

  // 🔥 FETCH CLIENT
  void fetchClientById() async {
    if (clientId.text.isEmpty) return;

    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/client/${clientId.text}"),
      );

      if (res.statusCode == 200 && res.body != "null") {
        var data = jsonDecode(res.body);

        setState(() {
          name.text = data["name"] ?? "";
          address.text = data["address"] ?? "";
          location.text = data["location"] ?? "";
          contactName.text = data["contactName"] ?? "";
          contactNo.text = data["contactNumber"] ?? "";
          email.text = data["email"] ?? "";
          message = "Data Loaded";
        });
      } else {
        setState(() => message = "Client Not Found");
      }
    } catch (e) {
      setState(() => message = "Server Error");
    }
  }

  // 🔥 NEXT ID
  void getNextId() async {
    if (isEditMode) return;

    try {
      var res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/client/nextId"),
      );

      if (res.statusCode == 200) {
        setState(() {
          clientId.text = res.body;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // 🔥 SAVE
  void saveClient() async {
    try {
      var res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/client/save"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": isEditMode ? int.parse(clientId.text) : null,
          "name": name.text,
          "address": address.text,
          "location": location.text,
          "contactName": contactName.text,
          "contactNumber": contactNo.text,
          "email": email.text,
        }),
      );

      if (res.statusCode == 200) {
        setState(() => message =
        isEditMode ? "Updated Successfully" : "Saved Successfully");

        clearForm();
        getNextId();
      } else {
        setState(() => message = "Save Failed");
      }
    } catch (e) {
      setState(() => message = "Server Error");
    }
  }

  // 🔥 DELETE
  void deleteClient() async {
    try {
      var res = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/client/${clientId.text}"),
      );

      if (res.statusCode == 200) {
        setState(() => message = "Deleted Successfully");
        clearForm();
        getNextId();
      } else {
        setState(() => message = "Delete Failed");
      }
    } catch (e) {
      setState(() => message = "Server Error");
    }
  }

  void clearForm() {
    name.clear();
    address.clear();
    location.clear();
    contactName.clear();
    contactNo.clear();
    email.clear();
    sameAsClient = false;
    isEditMode = false;
  }

  Widget actionButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Client Details")),
      body: Center(
        child: Container(
          width: 700,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    // CLIENT ID
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const SizedBox(width: 120, child: Text("Client ID")),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: clientId,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: fetchClientById,
                      child: const Text("Fetch Client"),
                    ),

                    Row(
                      children: [
                        const SizedBox(width: 120, child: Text("Client Name")),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: name,
                            onChanged: (val) {
                              if (sameAsClient) {
                                contactName.text = val;
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    rowMulti("Address", address),
                    row("Location", location, 250),

                    const SizedBox(height: 10),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Contact Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: sameAsClient,
                          onChanged: (val) {
                            setState(() {
                              sameAsClient = val!;
                              contactName.text =
                              sameAsClient ? name.text : "";
                            });
                          },
                        ),
                        const Text("Same as Client Name"),
                      ],
                    ),

                    row("Contact Name", contactName, 300),
                    row("Contact No", contactNo, 200),
                    row("Email", email, 300),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        actionButton("Save", saveClient),
                        const SizedBox(width: 10),
                        actionButton("Edit", () {
                          setState(() {
                            isEditMode = true;
                            message = "Enter Client ID & click Fetch";
                            clientId.clear();
                          });
                        }),
                        const SizedBox(width: 10),
                        actionButton("Delete", deleteClient),
                        const SizedBox(width: 10),
                        actionButton("Cancel", clearForm),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // 🔥 MAIN BUTTON
                    SizedBox(
                      width: 420,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ClientListPage(),
                            ),
                          );
                        },
                        child: const Text("Generate Client List"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      message,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget row(String label, TextEditingController c, double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          SizedBox(
            width: width,
            child: TextField(
              controller: c,
              decoration:
              const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  Widget rowMulti(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          SizedBox(
            width: 400,
            child: TextField(
              controller: c,
              maxLines: 3,
              decoration:
              const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }
}