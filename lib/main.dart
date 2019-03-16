import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_keepscreenon/flutter_keepscreenon.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

String sound = "gong1.mp3";
AudioCache gong = new AudioCache();
int before = 1260;
bool working = false;
int points = 0;

addIntToLocalStorage(String name, int value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt(name, value);
}

addStringToLocalStorage(String name, String value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(name, value);
}

Map<int, Color> color =
{
  50:Color(0xFF3F51B5),
  100:Color(0xFF3F51B5),
  200:Color(0xFF3F51B5),
  300:Color(0xFF3F51B5),
  400:Color(0xFF3F51B5),
  500:Color(0xFF3F51B5),
  600:Color(0xFF3F51B5),
  700:Color(0xFF3F51B5),
  800:Color(0xFF3F51B5),
  900:Color(0xFF3F51B5)
};

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      title: "SimpleMeditate",
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF3F51B5, color),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, String title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

double borderradius = 10;

class _MyHomePageState extends State<MyHomePage> {

  static var logoImage = new AssetImage('assets/logo.png');
  var logo = new ImageIcon(logoImage, color: Color(0xFF3F51B5), size: 60,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: IconButton(icon: logo,tooltip: "Settings", onPressed: () => _showDialog("Settings", Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("gong Sound",style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FloatingActionButton(onPressed: () {
                  sound = "gong1.mp3";
                  gong.play(sound);
                  addStringToLocalStorage("sound", sound);
                }, elevation: 0, backgroundColor: Colors.white, child: Text("1",style: TextStyle(color: Theme.of(context).primaryColor))),
                FloatingActionButton(onPressed: () {
                  sound = "gong2.mp3";
                  gong.play(sound);
                  addStringToLocalStorage("sound", sound);
                }, elevation: 0, backgroundColor: Colors.white, child: Text("2",style: TextStyle(color: Theme.of(context).primaryColor))),
                FloatingActionButton(onPressed: () {
                  sound = "gong3.mp3";
                  gong.play(sound);
                  addStringToLocalStorage("sound", sound);
                }, elevation: 0, backgroundColor: Colors.white, child: Text("3",style: TextStyle(color: Theme.of(context).primaryColor))),
                FloatingActionButton(onPressed: () {
                  sound = "gong4.mp3";
                  gong.play(sound);
                  addStringToLocalStorage("sound", sound);
                }, elevation: 0, backgroundColor: Colors.white, child: Text("4",style: TextStyle(color: Theme.of(context).primaryColor))),
              ],
            )
          ],
        ) ,"Ok")),
      ),
      body: _HomePage(),
    );
  }

  void _showDialog(String title, Widget content, String button) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: content,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderradius))),
          actions: <Widget>[
            new FlatButton(
              child: new Text(button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreen();
}

class HomeScreen extends State<_HomePage> {
  loadLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if(prefs.getInt("i") == null) {
        addIntToLocalStorage("i", before);
        i = before;
      } else {
        i = prefs.getInt("i");
      }
    });

    setState(() {
      if(prefs.getString("sound") == null){
        addStringToLocalStorage("sound", "sound.mp3");
      } else {
        sound = prefs.getString("sound");
      }
    });


    if(prefs.getInt("points") != null){
      setState(() {
        points = prefs.getInt("points");
      });
    } else {
      setState(() {
        addIntToLocalStorage("points", 0);
        points = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    FlutterKeepscreenon.keepScreenOn(true);
    loadLocalStorage();
  }

  String quote = 'Loading...';
  String quoteauther = "Loading...";

  Future getData() async {

    http.Response response = await http.get(
        Uri.encodeFull("https://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=en&json=?"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
        }
    );
    final data = jsonDecode(response.body);

    String check = data["quoteText"];
    print(data.toString());

    if(check.contains("'")){
      getData();
    } else {
      setState(() {
        quoteauther = data["quoteAuthor"];
        quote = data["quoteText"];
        addStringToLocalStorage("quote", quote);
        addStringToLocalStorage("quoteauther", quoteauther);
      });
    }
  }

  int ender = 0;
  int timerDowner = 1;

  int sec;
  int i = before;
  int hours;

  var timer;

  void startTimer() {
    if (working) {
      reset();
    } else {
      timer = new Timer.periodic(Duration(seconds: timerDowner), callback);
    }
  }

  void reset() async {
    timer.cancel();
    setState(() {
      i = before;
      working = false;
    });
  }

  void pausePlayer(Timer timer) async {
    print("End");
    gong.play(sound);
    Future.delayed(Duration(milliseconds: 1500), sound2);
    setState(() {
      this.i = before;
      timer.cancel();
    });
    working = false;
  }

  void startSound() {
    if (working) return;
    gong.play(sound);
  }

  void sound2() {
    gong.play(sound);
    Future.delayed(Duration(milliseconds: 1500), () => gong.play(sound));
  }

  void callback(Timer timer) async {
    final prefs = await SharedPreferences.getInstance();
    if (i == ender) {
      print("End");
      gong.play(sound);
      Future.delayed(Duration(milliseconds: 1500), sound2);

      setState(() {
        this.i = prefs.getInt("i");

        switch (prefs.getInt("i")) {
          case 60:
            points++;
            addIntToLocalStorage("points", points);
            break;
          case 420:
            points += 7;
            addIntToLocalStorage("points", points);
            break;
          case 1260:
            points += 21;
            addIntToLocalStorage("points", points);
            break;
          case 2520:
            points += 42;
            addIntToLocalStorage("points", points);
            break;
          case 3780:
            points += 63;
            addIntToLocalStorage("points", points);
            break;
        }

        timer.cancel();
      });
      working = false;
    } else {
      print("time is " + (i).toString());
      working = true;
      setState(() {
        i--;
      });
    }
  }

  void send(String text){
    Share.share(text);
  }

  @override
  Widget build(context) {
    return Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (working) return;
                  gong.play(sound);
                  setState(() {
                    this.i = {2520: 3780, 3780: 60, 60: 420, 420: 1260, 1260: 2520
                    }[this.i];
                    addIntToLocalStorage("i", this.i);
                    before = this.i;
                  });
                },
                child: Container(
                  width: 1000,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(((i / 60).floor()).toString().padLeft(2, '0') + ":" + (i % 60).toString().padLeft(2, '0'), style: TextStyle(fontSize: 70, fontWeight: FontWeight.bold, color: Colors.white)),
                      RaisedButton(
                        onPressed: () {
                          startTimer();
                          startSound();
                        },
                        color: Colors.white,
                        child: Text(working ? "Stop" : "Start", style: TextStyle(fontSize: 15, color: working ? Colors.red : Theme.of(context).primaryColor),),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(borderradius))),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.indigo[50],
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      )
                    ],
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(borderradius), bottomLeft: Radius.circular(borderradius)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("https://source.unsplash.com/collection/3330448/1600x900"),
                    ),
                  ),
                ),
              ),
            ),
            
          ],
          )
        )
      ],
    );
  }
}
