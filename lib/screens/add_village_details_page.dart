import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'generate_village_list_page.dart';

class AddVillageDetailsPage extends StatefulWidget {
  @override
  _AddVillageDetailsPageState createState() => _AddVillageDetailsPageState();
}

class _AddVillageDetailsPageState extends State<AddVillageDetailsPage> {

  TextEditingController village = TextEditingController();
  TextEditingController district = TextEditingController();
  TextEditingController taluka = TextEditingController();

  bool isEdit = false;
  int? selectedId;

  double labelWidth = 100;
  double fieldWidth = 300;
  double gap = 15;

  void saveOrUpdate() async {

    if (village.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Village required")));
      return;
    }

    var res;

    if (isEdit) {
      res = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/location/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": selectedId,
          "village": village.text,
          "district": district.text,
          "taluka": taluka.text,
        }),
      );
    } else {
      res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/location/save"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "village": village.text,
          "district": district.text,
          "taluka": taluka.text,
        }),
      );
    }

    print(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? "Updated Successfully" : "Saved Successfully")),
      );

      village.clear();
      district.clear();
      taluka.clear();
      selectedId = null;

      setState(() {
        isEdit = false;
      });

    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Operation Failed")));
    }
  }

  void fetchVillage() async {

    if (village.text.isEmpty) return;

    var res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/location/byVillage/${village.text}"),
    );

    if (res.statusCode == 200) {
      var data = jsonDecode(res.body);

      if (data.isNotEmpty) {
        setState(() {
          selectedId = data[0]["id"];
          district.text = data[0]["district"] ?? "";
          taluka.text = data[0]["taluka"] ?? "";
        });
      }
    }
  }

  void deleteVillage() async {

    if (village.text.isEmpty) return;

    await http.delete(
      Uri.parse("${ApiConfig.baseUrl}/location/delete/${village.text}"),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Deleted Successfully")));

    village.clear();
    district.clear();
    taluka.clear();
    selectedId = null;

    setState(() {
      isEdit = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Add Village Details")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Village")),
                SizedBox(
                  width: fieldWidth,
                  child: TextField(
                    controller: village,
                    onChanged: (val) {
                      if (isEdit && val.length > 1) {
                        fetchVillage();
                      }
                    },
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            SizedBox(height: gap),

            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("District")),
                SizedBox(
                  width: fieldWidth,
                  child: TextField(
                    controller: district,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            SizedBox(height: gap),

            Row(
              children: [
                SizedBox(width: labelWidth, child: Text("Taluka")),
                SizedBox(
                  width: fieldWidth,
                  child: TextField(
                    controller: taluka,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),

            Row(
              children: [
                buildBtn("Save", saveOrUpdate),
                buildBtn("Edit", () {
                  setState(() {
                    isEdit = true;
                  });
                }),
                buildBtn("Delete", deleteVillage),
                buildBtn("Cancel", () {
                  village.clear();
                  district.clear();
                  taluka.clear();
                  selectedId = null;

                  setState(() {
                    isEdit = false;
                  });
                }),
              ],
            ),

            SizedBox(height: 20),

            SizedBox(
              width: 430,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GenerateVillageListPage(),
                    ),
                  );
                },
                child: Text("Generate Village List"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBtn(String text, VoidCallback onClick) {
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 100,
        height: 40,
        child: ElevatedButton(
          onPressed: onClick,
          child: Text(text),
        ),
      ),
    );
  }
}