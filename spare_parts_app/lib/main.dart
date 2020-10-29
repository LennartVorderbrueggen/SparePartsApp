import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'dart:async';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spare Parts App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Spare Parts App',),
    );
  }
}

class Post {
  final String title;
  final String description;

  Post(this.title, this.description);
}

class Alert{
  final String action;
  final String articleName;
  final String location;
  final String machine;
  final String module;
  final String picture;
  Alert( this.action, this.articleName,this.location,this.machine, this.module, this.picture);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String barcode = "";
  SearchBar searchBar;
  final TextEditingController _filter = new TextEditingController();
  final dio = new Dio(); // for http requests
  String _searchText = "";
  List names = new List(); // names we get from API
  List filteredNames = new List(); // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search); 
  Widget _appBarTitle = new Text( 'Search Example' );


  _MyHomePageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          filteredNames = names;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void _getNames() async {
    final response = await dio.get('');
    List tempList = new List();
    // for (int i = 0; i < response.data['results'].length; i++) {
    //   tempList.add(response.data['results'][i]);
    // }
    tempList.add("Name1");
    tempList.add("Name2");
    tempList.add("Name3");
    tempList.add("Name4");
    setState(() {
        names = tempList;
        filteredNames = names;
      });
  }
  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search),
            hintText: 'Search...'
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search Example');
        filteredNames = names;
        _filter.clear();
      }
    });
  }

  Future scan() async {
    try {
      String barcode = await scanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == scanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  Future<List<Post>> search(String search) async {
    await Future.delayed(Duration(seconds: 2));
    return List.generate(search.length, (int index) {
      return Post(
        "Title : $search $index",
        "Description :$search $index",
      );
    });
  }

    Widget _buildList() {
    if (!(_searchText.isEmpty)) {
      List tempList = new List();
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]['name'].toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return ListView.builder(
      itemCount: names == null ? 0 : filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: Text(filteredNames[index]['name']),
          onTap: () => print(filteredNames[index]['name']),
        );
      },
    );
  }



  Widget _buildDashboard(){
    double width = MediaQuery. of(context). size. width;
    double height = MediaQuery. of(context). size. height;
    List alertList = new List();
    alertList.add(Alert("Ausfall", "AX800 GTS","Bielefeld Werk 2","Abfüllmaschine 12","Verschlussmodul", "Engine"));
    alertList.add(Alert("Warnung", "IoT Sensor","Bielefeld Werk 2","Abfüllmaschine 12","Wiegemodul", "Sensor"));
    return (Container(
      margin: new EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                 Card(
                    elevation: 5,
                    color: Colors.red,
                    child: SizedBox(
                      height: height*0.3,
                      width: width*0.9,
                    ),
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            width: 0, 
                            style: BorderStyle.none,
                        ),
                    ),
                  ),
                Card(
                    elevation: 5,
                    color: Colors.orange,
                    child: SizedBox(
                      height: height*0.3,
                      width: width*0.9,
                    ),
                    shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            width: 0, 
                            style: BorderStyle.none,
                        ),
                    ),
                  ),
      ],),
    ));
    // return (Container(
    //          child: Column(
    //          mainAxisSize: MainAxisSize.max,
    //          mainAxisAlignment: MainAxisAlignment.start,
    //          children: <Widget>[
    //            Expanded(
    //              child: ListView.builder(
    //             // scrollDirection: Axis.horizontal,
    //                  itemCount: alertList.length,
    //                  itemBuilder: (context, index) {
    //                  return Container(
    //                    padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
    //                    height: 220,
    //                    width: double.maxFinite,
    //                    child: Card(
    //                      elevation: 5,
    //                      child: Container(
    //                        decoration: BoxDecoration(
    //                          border: Border(
    //                            top: BorderSide(width: 2.0, color: Colors.red),
    //                          ),
    //                          color: Colors.white,
    //                        ),
    //                        child: Padding(
    //                          padding: EdgeInsets.all(7),
    //                          child: Stack(children: <Widget>[
    //                            Align(
    //                              alignment: Alignment.centerRight,
    //                              child: Stack(
    //                                children: <Widget>[
    //                                  Padding(
    //                                      padding: const EdgeInsets.only(left: 10, top: 5),
    //                                      child: Column(
    //                                        children: <Widget>[
    //                                          Row(
    //                                            children: <Widget>[
    //                                            //cryptoIcon(cryptoData[index]),
    //                                            SizedBox(
    //                                              height: 10,
    //                                            ),
    //                                           //  cryptoNameSymbol(cryptoData[index]),
    //                                            Spacer(),
    //                                           //  cryptoChange(cryptoData[index]),
    //                                            SizedBox(
    //                                              width: 10,
    //                                            ),
    //                                           //  changeIcon(cryptoData[index]),
    //                                            SizedBox(
    //                                              width: 20,
    //                                            )
    //                                          ],
    //                                        ),
    //                                    ],
    //                                   ))
    //                              ],
    //                            ),
    //                          )
    //                        ]),
    //                      ),
    //                    ),
    //                  ),
    //                );
    //         }),
    //         ),
    //         ],
    //         ),
    //         )
    //         );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
      ),
      drawer: Drawer(child: 
                    ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: Text(widget.title, style: TextStyle(color: Colors.white ,fontWeight: FontWeight.bold, fontSize: 25),),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                      ),
                    ),
                    ListTile(
                      leading: new Icon(Icons.dashboard, color: Colors.black,),
                      title: Text('Dashboard'),
                      onTap: () {
                      },
                    ),
                    ListTile(
                      leading: new Icon(Icons.shopping_cart, color: Colors.black,),
                      title: Text('Bestellungen'),
                      onTap: () {
                      },
                    ),
                    ListTile(
                      leading: new Icon(Icons.account_balance, color: Colors.black,),
                      title: Text('Adressen'),
                      onTap: () {
                      },
                    ),
                    ListTile(
                      leading: new Icon(Icons.account_circle, color: Colors.black,),
                      title: Text('Konto'),
                      onTap: () {
                      },
                    ),
                  ],
                ),
      ),
      body: Stack(
            alignment: Alignment.topCenter,
            children: [
              Center(
              child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(30),
                  child: 
                TextField(
                  controller: _filter,
                  decoration: new InputDecoration(
                    filled: true,
                    fillColor:  Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(
                            width: 0, 
                            style: BorderStyle.none,
                        ),
                    ),
                    prefixIcon: new Icon(Icons.search),
                    hintText: 'Search...'
                  ),
                ),
                ),
                _buildDashboard(),
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$barcode',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ],
              ),

            ),
            ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: scan,
        tooltip: 'Open QR-Code Scanner',
        child: Icon(Icons.camera_alt, color: Colors.black,),
      ),
    );
  }
}