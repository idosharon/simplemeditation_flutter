import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_keepscreenon/flutter_keepscreenon.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

//global vars
String songfile = "gong1.mp3";
AudioCache gong = new AudioCache();
int latesI = 1260;
bool working = false;
int mypoints = 0;
double coins = mypoints/2;

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

MaterialColor colorCustom = MaterialColor(0xFF3F51B5, color);

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
        primarySwatch: colorCustom,
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
  var logo = new Image(image: logoImage, width: 43, height:  43,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(child: logo),
        leading: IconButton(icon: Icon(Icons.info), color: Theme.of(context).primaryColor,onPressed: () => _showDialog("About SimpleMind",
            Column(
              children: <Widget>[
                Text("This App created by Ido Sharon")
              ],
            )
            , "Cool"),),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), color: Theme.of(context).primaryColor,onPressed: () => _showDialog("Settings", Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("gong Sound\n",style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(onPressed: () {
                    songfile = "gong1.mp3";
                    gong.play(songfile);
                  }, elevation: 0, backgroundColor: Colors.white, child: Text("1",style: TextStyle(color: Theme.of(context).primaryColor))),
                  FloatingActionButton(onPressed: () {
                    songfile = "gong2.mp3";
                    gong.play(songfile);
                  }, elevation: 0, backgroundColor: Colors.white, child: Text("2",style: TextStyle(color: Theme.of(context).primaryColor))),
                  FloatingActionButton(onPressed: () {
                    songfile = "gong3.mp3";
                    gong.play(songfile);
                  }, elevation: 0, backgroundColor: Colors.white, child: Text("3",style: TextStyle(color: Theme.of(context).primaryColor))),
                  FloatingActionButton(onPressed: () {
                    songfile = "gong4.mp3";
                    gong.play(songfile);
                  }, elevation: 0, backgroundColor: Colors.white, child: Text("4",style: TextStyle(color: Theme.of(context).primaryColor))),
                ],
              )
            ],
          ) ,"Ok"),)
        ],
      ),
      body: _HomePage(),
    );
  }

  Widget _showDialog(String title, Widget content, String Buttonstring) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: content,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderradius))),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(Buttonstring),
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
  //alert

  //localStorage Fun
  //add
  addIntToLocalStorage(String name, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(name, value);
  }

  addStringToLocalStorage(String name, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(name, value);
  }

  addDoubleToLocalStorage(String name, double value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(name, value);
  }

  //api start
  String quote = "Loading...";
  String quoteauther = "Loading...";

  loadLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      i = prefs.getInt("i");
    });
    if(prefs.getInt("points") == 0){
      setState(() {
        mypoints = prefs.getInt("points");
        coins = mypoints/2;
      });
    } else {
      setState(() {
        addIntToLocalStorage("points", 0);
        mypoints = prefs.getInt("points");
        coins = mypoints/2;
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

  Future getData() async {
    http.Response response = await http.get(
        Uri.encodeFull("https://api.forismatic.com/api/1.0/?method=getQuote&format=json&lang=en&json=?"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json",
        }
    );

    final data = jsonDecode(response.body);

    print(data.toString());

    setState(() {
      quoteauther = data["quoteAuthor"];
      quote = data["quoteText"];
      addStringToLocalStorage("quote", quote);
      addStringToLocalStorage("quoteauther", quoteauther);
    });
  }

  //api end

  //points!!!
  //vars

  //meditation timer
  int ender = 0;
  int timerDowner = 1;

  int sec;
  int i = latesI;
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
      i = latesI;
      working = false;
    });
  }

  void pausePlayer(Timer timer) async {
    print("End");
    gong.play(songfile);
    Future.delayed(Duration(milliseconds: 1500), sound2);
    setState(() {
      this.i = latesI;
      timer.cancel();
    });
    working = false;
  }

  void startSound() {
    if (working) return;
    gong.play(songfile);
  }

  void sound2() {
    gong.play(songfile);
    Future.delayed(Duration(milliseconds: 1500), sound3);
  }

  void sound3() {
    gong.play(songfile);
  }

  void callback(Timer timer) async {
    if (i == ender) {
      print("End");
      gong.play(songfile);
      Future.delayed(Duration(milliseconds: 1500), sound2);

      setState(() {
        switch (latesI) {
          case 60:
            mypoints++;
            break;
          case 420:
            mypoints += 7;
            break;
          case 1260:
            mypoints += 21;
            break;
          case 2520:
            mypoints += 42;
            break;
          case 3780:
            mypoints += 63;
            break;
        }


        //add to localstorage
        addIntToLocalStorage("points", mypoints);

        setState(() {
          coins = mypoints / 2;
        });

        this.i = latesI;

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
                    gong.play(songfile);
                    setState(() {
                      this.i = {
                        2520: 3780,
                        3780: 60,
                        60: 420,
                        420: 1260,
                        1260: 2520
                      }[this.i];
                      addIntToLocalStorage("i", this.i);
                      latesI = this.i;
                    });
                  },
                  child: Container(
                    width: 1000,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(((i / 60).floor()).toString().padLeft(2, '0') +
                            ":" + (i % 60).toString().padLeft(2, '0'),
                            style: TextStyle(fontSize: 70,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        RaisedButton(
                          onPressed: () {
                            startTimer();
                            startSound();
                          },
                          color: Colors.white,
                          child: Text(
                            working ? "Stop" : "Start", style: TextStyle(
                              fontSize: 15, color: working ? Colors.red : Theme
                              .of(context)
                              .primaryColor),),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(borderradius))),
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
                        image: NetworkImage(
                            "https://source.unsplash.com/collection/3330448/1600x900"),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      card(Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("\nThe Daily quote\n", style: TextStyle(
                              fontWeight: FontWeight.bold)),
                          Text(quote.toString(), style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme
                                  .of(context)
                                  .primaryColor),
                            textAlign: TextAlign.center,),
                          Text(quoteauther.toString(),
                            style: TextStyle(
                                fontSize: 12, color: Theme
                                .of(context)
                                .primaryColor),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  startSound();
                                  Share.share(
                                      "Check out this quote - '" +
                                          quote.toString() +
                                          "' His Auther is - " +
                                          quoteauther.toString());
                                },
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                icon: Icon(Icons.share),
                                splashColor: Colors.transparent,
                              ),
                            ],
                          )
                        ],
                      ), 400),
                      //coins
                      card(Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text("\nExperience\n", style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,),
                                  Text(mypoints.toString() + " min\n",
                                    style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme
                                            .of(context)
                                            .primaryColor),
                                    textAlign: TextAlign.center,),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Text("\nCoins\n", style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,),
                                  Text((coins).toString() + " coins\n",
                                    style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme
                                            .of(context)
                                            .primaryColor),
                                    textAlign: TextAlign.center,),
                                ],
                              )
                            ],
                          ),
                        ],
                      ), 400),

                    ],
                  )
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget card(Widget child, double width) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: child,
          ),
        ),
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            new BoxShadow(
              color: Colors.indigo[50],
              blurRadius: 5,
              offset: Offset(0, 0),
            )
          ],
          borderRadius: BorderRadius.circular(
              borderradius),
        ),
      ),
    );
  }

}


