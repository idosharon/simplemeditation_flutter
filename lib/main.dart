import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:splashscreen/splashscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
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

  int _selected = 0;
  List<StatefulWidget> _screens = [
    _HomePage(),
    _SettingPage(),
  ];

  static var logoImage = new AssetImage('assets/logo.png');
  var logo = new Image(image: logoImage, width: 43, height:  43,);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: logo,
        backgroundColor: Colors.white,
        elevation: 0,

      ),
      body: _screens[_selected],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Home")),
          BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text("Settings")),
        ],
        currentIndex: _selected,
        fixedColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selected = index;
    });
  }
}

class _SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingPage();
}

class SettingPage extends State<_SettingPage> {
  @override
  Widget build(context) {
    return new Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("About", style: TextStyle(fontWeight: FontWeight.bold),),
              Text("This app created by Ido Sharon.")
            ],
          ),
          height: 90,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              new BoxShadow(
                color: Colors.indigo[50],
                blurRadius: 5,
                offset: Offset(0, 0),
              )
            ],
            borderRadius: BorderRadius.circular(borderradius),
          ),
        )
    );
  }
}

class _HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeScreen();
}

class HomeScreen extends State<_HomePage> {
  //api start
  String quote;
  String auther;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    http.Response response = await http.get(
        Uri.encodeFull("https://thesimpsonsquoteapi.glitch.me/quotes"),
        headers: {
          "Accept": "application/json",
        }
    );

    final data = jsonDecode(response.body);

    quote = data[0]["quote"];
    auther = data[0]["character"];

    print(quote);
    if(quote.length > 100) {
      getData();
    } else {
      setState(() {
        quote;
        auther;
      });
    }

  }
  
  //meditation timer :
  String songfile = "gong1.mp3";
  int ender = 0;
  int latesI = 21;
  int timerDowner = 1;
  static AudioCache Gong = new AudioCache();


  int sec;
  int i = 21;
  int hours;

  bool working = false;

  var timer;

  void StartTimer() {
    if(working) {
      reset();
    } else {
      timer = new Timer.periodic(Duration(seconds: timerDowner), callback);
      i = i * 60;
    }
  }

  void reset() {
    timer.cancel();
    setState(() {
      i = latesI;
      working = false;
    });
  }

  void pausePlayer(Timer timer) {
    print("End");
    Gong.play(songfile);
    Future.delayed(Duration(milliseconds: 1500), Sound2);
    setState(() {
      this.i = latesI;
      timer.cancel();
    });
    working = false;
  }

  void startSound() {
    if(working) return;
    Gong.play(songfile);

  }
  void Sound2() {
    Gong.play(songfile);
    Future.delayed(Duration(milliseconds: 1500), Sound3);
  }
  void Sound3() {
    Gong.play(songfile);
  }
  void callback(Timer timer) {
    if(i == ender){
      print("End");
      Gong.play(songfile);
      Future.delayed(Duration(milliseconds: 1500), Sound2);
      setState(() {
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

  //widget

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
                      Gong.play(songfile);
                      setState(() {
                        this.i = {42: 63, 63: 1, 1: 7, 7: 21, 21: 42}[this.i];
                        latesI = this.i;
                    });
                  },
                  child: Container(
                    width: 1000,
                    height: 370,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text("$i",style: TextStyle(fontSize: 70,fontWeight: FontWeight.bold, color: Colors.white)),
                        RaisedButton(
                          onPressed: () {
                            StartTimer();
                            startSound();
                          },
                          color: Colors.white,
                          child: Text(
                            working ? "Stop" : "Start", style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),),
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
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(borderradius),
                        bottomRight: Radius.circular(borderradius),
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            "https://source.unsplash.com/collection/3330448/1600x900"),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Bowl Sound",style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  FloatingActionButton(onPressed: () {
                                    songfile = "gong1.mp3";
                                    Gong.play(songfile);
                                  }, elevation: 0, backgroundColor: Colors.white, child: Text("1",style: TextStyle(color: Theme.of(context).primaryColor))),
                                  FloatingActionButton(onPressed: () {
                                    songfile = "gong2.mp3";
                                    Gong.play(songfile);
                                  }, elevation: 0, backgroundColor: Colors.white, child: Text("2",style: TextStyle(color: Theme.of(context).primaryColor))),
                                  FloatingActionButton(onPressed: () {
                                    songfile = "gong3.mp3";
                                    Gong.play(songfile);
                                  }, elevation: 0, backgroundColor: Colors.white, child: Text("3",style: TextStyle(color: Theme.of(context).primaryColor))),
                                  FloatingActionButton(onPressed: () {
                                    songfile = "gong4.mp3";
                                    Gong.play(songfile);
                                  }, elevation: 0, backgroundColor: Colors.white, child: Text("4",style: TextStyle(color: Theme.of(context).primaryColor))),
                                ],
                              )
                            ],
                          ),
                          height: 90,
                          width: 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              new BoxShadow(
                                color: Colors.indigo[50],
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(borderradius),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 20, right: 20, bottom: 20),
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text("Simpsons quotes to make you laugh!\n",style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),),
                                  Text('"' + quote.toString() + '"',style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor),textAlign: TextAlign.center,),
                                  Text(auther.toString(),style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),textAlign: TextAlign.center,),
                                  RaisedButton(
                                    onPressed: () {
                                      getData();
                                      startSound();
                                    },
                                    color: Colors.white,
                                    child: Icon(Icons.refresh),
                                    elevation: 0,
                                    splashColor: Colors.indigo[100],
                                  ),
                                ],
                              ),
                              width: 400,
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
                          )
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }

}

