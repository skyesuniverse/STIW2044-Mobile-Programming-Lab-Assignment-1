import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';

void main() => runApp(const CountryInfoScreen());

class CountryInfoScreen extends StatelessWidget {
  const CountryInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Country Info App'),
        ),
        body: const HomePage(),
      ),
    );
  }
}

////////////////////////////////////////

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController countryNameEditingController = TextEditingController();

  //declare variable
  var countrydata = "", countryName = "";
  var name = "", capital = "", currencyName = "", currencyCode = "", iso2 = "";
  final player = AudioPlayer();
  ImageProvider? flag;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              'assets/images/country pic.png',
              scale: 9,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "- Know the country -",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: countryNameEditingController,
                    decoration: InputDecoration(
                        hintText: "Input country name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(1))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: _getCountry,
                    child: const Text("Search"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 280, // set the width to 200 pixels
                    height: 200,
                    padding: const EdgeInsets.all(13.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.black26,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          countrydata,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        if (flag != null)
                          Image(image: flag!)
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCountry() async {
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Progress"), title: const Text("Searching..."));
    progressDialog.show();

    countryName = countryNameEditingController.text;

    if (countryName.isEmpty) {
      setState(() {
        progressDialog.dismiss();
        countrydata = "Please enter a country name";
        flag = null;
      });

      return;
    }

    var apiKey = "rdkae73eZpne2fUPpAJlEg==wF9vk8evRT3ySns5";
    var url =
        Uri.parse('https://api.api-ninjas.com/v1/country?name=$countryName');
    var response = await http.get(url, headers: {"X-Api-Key": apiKey});

    if (response.statusCode == 200) {
      var jsonData = response.body;
      var parsedJson = json.decode(jsonData);

      if (parsedJson.isNotEmpty) {
        var resultCountryName = parsedJson[0]['name'];

        if (resultCountryName.toLowerCase() == countryName.toLowerCase()) {
          name = resultCountryName;
          capital = parsedJson[0]['capital'];
          currencyName = parsedJson[0]['currency']['name'];
          currencyCode = parsedJson[0]['currency']['code'];
          iso2 = parsedJson[0]['iso2'];
          countrydata =
              "This country is $name. The capital of $name is $capital. Currency used for this country is $currencyName ($currencyCode).";

          //Image flag = Image.network("https://flagsapi.com/$iso2/flat/64.png");
          flag = NetworkImage("https://flagsapi.com/$iso2/flat/64.png");
          //print(jsonData);
          //print(parsedJson);

          setState(() {});
          progressDialog.dismiss();
          player.play(AssetSource('audios/correct_sound.wav'));
        } else {
          progressDialog.dismiss();
          player.play(AssetSource('audios/wrong_sound.wav'));
          countrydata = "Please enter valid country name";
          flag = null;
          setState(() {});
        }
      }
      //if statement
    }
  }
}
