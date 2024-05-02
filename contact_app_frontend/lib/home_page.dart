import 'dart:convert';
import 'package:crud_api/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameInputController = TextEditingController();
  final _phoneInputController = TextEditingController();

  // Map mapResponse = {};

  List listResponse = [];

  //SEND DATA FUNCTION
  void sendData() async {
    if (_nameInputController.text.isNotEmpty &&
        _phoneInputController.text.isNotEmpty) {
      var dataBody = {
        "name": _nameInputController.text,
        "phone": _phoneInputController.text
      };

      var response = await http.post(Uri.parse(baseUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(dataBody));

      var jsonResponse = jsonDecode(response.body);
      _nameInputController.clear();
      _phoneInputController.clear();

      final snackBar = SnackBar(
        backgroundColor: Colors.green,
        content: Text(jsonResponse['message'],
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500)),
        duration:
            Duration(seconds: 3), // Duration for which snackbar will be visible
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      apiCall();
    }
  }
  //SEND DATA FUNCTION

  //GET DATA FUNCTION

  Future<void> apiCall() async {
    http.Response response;

    response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      setState(() {
        // mapResponse = json.decode(response.body);
        // print(mapResponse);
        listResponse = json.decode(response.body);
      });
    }
  }
  //GET DATA FUNCTION

  //DELETE DATA

  void deleteContact(id) async {
    http.Response response;

    response = await http.delete(Uri.parse(baseUrl + id));

    print(response.body);
    var jsonResponse = jsonDecode(response.body);

    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        jsonResponse['message'],
        style: TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
      ),
      duration:
          Duration(seconds: 3), // Duration for which snackbar will be visible
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //DELETE DATA

  //UPDATE DATA
  Map updateData = {};

  void updateValue(name, phone, id) async {
      updateData = {"id":id, "name": name, "phone": phone};
  }

  void updateContact()async{
      var dataBody = {
        "name": _nameInputController.text,
        "phone": _phoneInputController.text
      };

        var response = await http.patch(Uri.parse(baseUrl + updateData["id"]),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dataBody));
        _nameInputController.clear();
        _phoneInputController.clear();
        apiCall();
  }
  //UPDATE DATA

  @override
  void initState() {
    apiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Contact List",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameInputController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _phoneInputController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Rounded corners
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          sendData();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          updateContact();
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            listResponse.isEmpty
                ? Text("No Contacts Yet...")
                : Expanded(
                    child: ListView.builder(
                        itemCount: listResponse.length,
                        itemBuilder: (context, index) => getRow(index)),
                  )
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          child: Text(
            listResponse[index]["name"][0].toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
          ),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listResponse[index]["name"]),
            SizedBox(
              height: 8,
            )
          ],
        ),
        titleTextStyle: TextStyle(fontSize: 20, color: Color(0xff333333)),
        subtitleTextStyle: TextStyle(fontSize: 18, color: Color(0xff666666)),
        subtitle: Text("+91 " + listResponse[index]["phone"]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  deleteContact(listResponse[index]["_id"]);
                  apiCall();
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _nameInputController.text = listResponse[index]["name"];
                    _phoneInputController.text = listResponse[index]["phone"];
                  });

                  updateValue(listResponse[index]["name"],
                      listResponse[index]["phone"], listResponse[index]["_id"]);
                },
                icon: Icon(Icons.edit))
          ],
        ),
      ),
    );
  }
}

// Row(
//                children: [
//                 IconButton.filled(onPressed: (){}, icon: Icon(Icons.edit_document)),
//                 IconButton.filled(onPressed: (){}, icon: Icon(Icons.delete)),
//                ],
//             ),
