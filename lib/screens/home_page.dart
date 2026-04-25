import 'package:flutter/material.dart';
import 'add_client_details_page.dart';
import 'add_case_details.dart';
import 'arbitration_case_details_page.dart';
import 'add_project_details_page.dart';
import 'add_village_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showMaster = false;
  bool showCase = false;
  bool showNHAISubMenu = false;

  final double menuHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // 🔥 Logo
            SizedBox(
              height: 30,
              child: Image(image: AssetImage("assets/logo.png")),
            ),
            SizedBox(width: 10),
            Text(
              "CaseDairy",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [

          // 🔹 MAIN BODY
          Column(
            children: [

              // 🔹 MENU BAR
              Container(
                height: menuHeight,
                width: double.infinity,
                color: const Color(0xFF1B263B),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showMaster = !showMaster;
                          showCase = false;
                          showNHAISubMenu = false;
                        });
                      },
                      child: menuText("Master"),
                    ),

                    const SizedBox(width: 30),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showCase = !showCase;
                          showMaster = false;
                          showNHAISubMenu = false;
                        });
                      },
                      child: menuText("Case Details"),
                    ),

                    const SizedBox(width: 30),
                    menuText("Reports"),

                    const SizedBox(width: 30),
                    menuText("Billing"),
                  ],
                ),
              ),

              // 🔹 BODY
              const Expanded(
                child: Center(
                  child: Text(
                    "Welcome to CaseDairy",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),

          // 🔻 MASTER SUBMENU
          if (showMaster)
            Positioned(
              top: menuHeight,
              left: 20,
              child: subMenuContainer([
                subMenuItem("Add Client Details", () {
                  closeMenus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddClientPage()),
                  );
                }),
                subMenuItem("Add Project Details", () {
                  closeMenus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddProjectPage()),
                  );
                }),
                subMenuItem("Add Village Details", () {
                  closeMenus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddVillageDetailsPage()),
                  );
                }),

              ]),
            ),

          // 🔻 CASE SUBMENU
          if (showCase)
            Positioned(
              top: menuHeight,
              left: 130,
              child: subMenuContainer([

                // 🔹 NHAI
                ListTile(
                  dense: true,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("NHAI Case Details",
                          style: TextStyle(fontSize: 14)),
                      Icon(Icons.arrow_right),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      showNHAISubMenu = !showNHAISubMenu;
                    });
                  },
                ),

                subMenuItem("Add Case Details", () {
                  closeMenus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddCasePage()),
                  );
                }),
              ]),
            ),

          // 🔻 NHAI SUBMENU
          if (showNHAISubMenu)
            Positioned(
              top: menuHeight,
              left: 330,
              child: subMenuContainer([
                subMenuItem("Arbitration", () {
                  closeMenus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArbitrationCaseDetailsPage(
                        title: "Arbitration Case Details",
                      ),
                    ),
                  );
                }),
                subMenuItem("District Court", () {}),
                subMenuItem("High Court", () {}),
                subMenuItem("Supreme Court", () {}),
              ]),
            ),
        ],
      ),
    );
  }

  // 🔥 CLOSE MENUS
  void closeMenus() {
    setState(() {
      showMaster = false;
      showCase = false;
      showNHAISubMenu = false;
    });
  }

  // 🔹 MENU TEXT
  Widget menuText(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  // 🔹 SUBMENU BOX
  Widget subMenuContainer(List<Widget> children) {
    return Material(
      elevation: 4,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
        ),
        child: Column(children: children),
      ),
    );
  }

  // 🔹 SUBMENU ITEM
  Widget subMenuItem(String title, VoidCallback onTap) {
    return ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
    );
  }
}