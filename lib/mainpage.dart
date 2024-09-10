import 'package:doj/ai.dart';
import 'package:doj/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Departmentofjustice extends StatefulWidget {
  const Departmentofjustice({super.key});

  @override
  State<Departmentofjustice> createState() => _DepartmentofjusticeState();
}

class _DepartmentofjusticeState extends State<Departmentofjustice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Department of Justice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.gavel),
              title: Text(
                'Text Assistant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text(
                'Voice Assistant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AIpage(data: "")),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center content vertically
            children: [
              // Display the image with a rectangular shape
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    10), // Adjust the border radius if needed
                child: SvgPicture.network(
                  'https://doj.gov.in/wp-content/themes/sdo-theme/images/emblem.svg', // SVG image URL
                  width: 300, // Adjust the width as needed
                  height: 200, // Adjust the height as needed
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),
              SizedBox(
                  height:
                      20), // Add some spacing between the image and the button
              Text(
                'Welcome to the Department of Justice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
Padding(
  padding: const EdgeInsets.only(left:75.0),
  child: Column(
       mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ListTile(
                      leading: Icon(Icons.chat),
                      title: Text(
                        'Voice Assistant',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AIpage(data: "")),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.chat),
                      title: Text(
                        'Voice Assistant',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AIpage(data: "")),
                        );
                      },
                    ),ListTile(
                    leading: Icon(Icons.chat),
                    title: Text(
                      'Voice Assistant',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AIpage(data: "")),
                      );
                    },
                  ),
    ],
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}
