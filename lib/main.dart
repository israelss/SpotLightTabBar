import 'package:animated_tab_bar/spot_light_tab_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

const kMainColor = Color.fromARGB(255, 123, 121, 123);
const kMainBackColor = Color.fromARGB(255, 60, 58, 60);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpotLightTabBar Demo',
      home: MyHomePage(title: 'SpotLightTabBar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: kMainBackColor,
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.grey,
        child: TabBarView(
          children: [
            Center(child: Text('Shop')),
            Center(child: Text('Favorite')),
            Center(child: Text('Search')),
          ],
          controller: _tabController,
        ),
      ),
      bottomNavigationBar: SpotLightTabBar(
        controller: _tabController,
        backgroundColor: kMainBackColor,
        tabs: <Widget>[
          Tab(icon: Icon(Icons.local_mall)),
          Tab(icon: Icon(Icons.favorite_border)),
          Tab(icon: Icon(Icons.search)),
        ],
      ),
    );
  }
}
