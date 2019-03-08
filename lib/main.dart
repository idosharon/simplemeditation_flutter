import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_keepscreenon/flutter_keepscreenon.dart';
import 'package:share/share.dart';

//global vars
String songfile = "gong1.mp3";
AudioCache Gong = new AudioCache();
int latesI = 1260;
bool working = false;
int mypoints = 0;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
        title: Center(child: logo,),
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
      if(!working) {
        _selected = index;
      } else {

      }
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("About", style: TextStyle(fontWeight: FontWeight.bold),),
                Text("This app created by Ido Sharon."),
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
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Gong Sounds",style: TextStyle(fontWeight: FontWeight.bold)),
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
        ],
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
  String quote = "Loading...";
  String quoteauther = "Loading...";

  @override
  void initState() {
    super.initState();
    getData();
    FlutterKeepscreenon.keepScreenOn(true);
  }

  Future getData() async {
    http.Response response = await http.get(
        Uri.encodeFull("https://quotes.rest/qod.json"),
        headers: {
          "Accept": "application/json",
          "content-type": "application/json"
        }
    );

    final data = jsonDecode(response.body);

    quote = data["contents"]["quotes"][0]["quote"];
    quoteauther = data["contents"]["quotes"][0]["author"];

    print("quote: " + quote);
    setState(() {
      quote.toString();
      quoteauther.toString();
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

  void StartTimer() {
    if(working) {
      reset();
    } else {
      timer = new Timer.periodic(Duration(seconds: timerDowner), callback);
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
      setState(() {

      });
      Future.delayed(Duration(milliseconds: 1500), Sound2);
      setState(() {
        switch(latesI) {
          case 60: mypoints++;
          break;
          case 420: mypoints += 7;
          break;
          case 1260: mypoints += 21;
          break;
          case 2520: mypoints += 42;
          break;
          case 3780: mypoints += 63;
          break;
        }

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
                      Gong.play(songfile);
                      setState(() {
                        this.i = {2520: 3780, 3780: 60, 60: 420, 420: 1260, 1260: 2520}[this.i];
                        latesI = this.i;
                    });
                  },
                  child: Container(
                    width: 1000,
                    height: 600,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(((i/60).floor()).toString().padLeft(2,'0') + ":" + (i%60).toString().padLeft(2,'0'),style: TextStyle(fontSize: 70,fontWeight: FontWeight.bold, color: Colors.white)),
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
                      padding: EdgeInsets.only(left: 10,top: 10,right: 10),
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("The Daily quote\n",style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(quote.toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),textAlign: TextAlign.center,),
                              Text(quoteauther.toString(), style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      startSound();
                                      Share.share("Check out this quote - '" + quote.toString() + "' His Auther is - " + quoteauther.toString());
                                    },
                                    color: Theme.of(context).primaryColor,
                                    icon: Icon(Icons.share),
                                    splashColor: Colors.transparent,
                                  ),
                                ],
                              )

                            ],
                          ),
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
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Experience Points\n",style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(mypoints.toString(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),textAlign: TextAlign.center,),
                              ],
                            ),
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
                      ),
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

