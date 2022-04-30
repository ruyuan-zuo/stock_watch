import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// import 'show_stock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetail {
  //https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=c9guatqad3iblo2fo3e0
  /*
  {"country":"US","currency":"USD","exchange":"NASDAQ NMS - GLOBAL MARKET",
  "finnhubIndustry":"Technology","ipo":"1980-12-12","logo":"https://static.finnhub.io/logo/87cb30d8-80df-11ea-8951-00000000092a.png",
  "marketCapitalization":2693850,"name":"Apple Inc","phone":"14089961010.0",
  "shareOutstanding":16319.44,"ticker":"AAPL","weburl":"https://www.apple.com/"}
   */
  final String name;
  final String symbol;
  final String startDate;
  final String industry;
  final String website;
  final String exchange;
  final double marketCap;

  CompanyDetail(
      {required this.name,
      required this.symbol,
      required this.startDate,
      required this.industry,
      required this.website,
      required this.exchange,
      required this.marketCap});

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    return CompanyDetail(
      name: json["name"] as String,
      symbol: json["ticker"] as String,
      startDate: json["ipo"] as String,
      industry: json["finnhubIndustry"] as String,
      website: json["weburl"] as String,
      exchange: json["exchange"] as String,
      marketCap: checkDouble(json["marketCapitalization"]),
    );
  }
}

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

int checkInt(dynamic value) {
  if (value is int)
    return value;
  else if (value is double)
    return value.toInt();
  else {
    return int.parse(value);
  }
}

class Stock {
  //https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0
  final double currentPrice;
  final double dchange;
  final double dpercentChange;
  final double highPriceOfDay;
  final double lowPriceOfDay;
  final double openPriceOfDay;
  final double previousClosePrice;
  final int t;

  Stock(
      {required this.currentPrice,
      required this.dchange,
      required this.dpercentChange,
      required this.highPriceOfDay,
      required this.lowPriceOfDay,
      required this.openPriceOfDay,
      required this.previousClosePrice,
      required this.t});

  bool checknullValue() {
    return [
      currentPrice,
      dchange,
      openPriceOfDay,
      highPriceOfDay,
      lowPriceOfDay,
      previousClosePrice
    ].contains(null);
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      currentPrice: checkDouble(json["c"]),
      dchange: checkDouble(json["d"]),
      dpercentChange: checkDouble(json["dp"]),
      highPriceOfDay: checkDouble(json["h"]),
      lowPriceOfDay: checkDouble(json["l"]),
      openPriceOfDay: checkDouble(json["o"]),
      previousClosePrice: checkDouble(json["pc"]),
      t: checkInt(json["t"]),
    );
  }
}

class InforPage {
  //https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0
  final double currentPrice;
  final double dchange;
  final double dpercentChange;
  final double highPriceOfDay;
  final double lowPriceOfDay;
  final double openPriceOfDay;
  final double previousClosePrice;
  final int t;
  final String name;
  final String symbol;
  final String startDate;
  final String industry;
  final String website;
  final String exchange;
  final double marketCap;

  InforPage(
      {required this.currentPrice,
      required this.dchange,
      required this.dpercentChange,
      required this.highPriceOfDay,
      required this.lowPriceOfDay,
      required this.openPriceOfDay,
      required this.previousClosePrice,
      required this.t,
      required this.name,
      required this.symbol,
      required this.startDate,
      required this.industry,
      required this.website,
      required this.exchange,
      required this.marketCap});
}

class SearchEntry {
  final String description;
  final String displaySymbol;

  const SearchEntry({required this.description, required this.displaySymbol});

  factory SearchEntry.fromJson(Map<String, dynamic> json) {
    return SearchEntry(
      description: json["description"] as String,
      displaySymbol: json["displaySymbol"] as String,
    );
  }

  static Map<String, dynamic> toMap(SearchEntry entry) => {
        'description': entry.description,
        'displaySymbol': entry.displaySymbol,
      };

  static String encode(List<SearchEntry> entries) => json.encode(
        entries
            .map<Map<String, dynamic>>((entry) => SearchEntry.toMap(entry))
            .toList(),
      );
}

class CompeletSearch {
  final int number;
  final List<SearchEntry> listOfRes;

  CompeletSearch({required this.number, required this.listOfRes});

  factory CompeletSearch.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['result'] as List;
    // print(list.runtimeType); //returns List<dynamic>
    List<SearchEntry> entryList =
        list.map((i) => SearchEntry.fromJson(i)).toList();
    return CompeletSearch(number: parsedJson['count'], listOfRes: entryList);
  }
}

Future<CompeletSearch> fetchSearchList(String url_sub) async {
  try {
    String url = "https://finnhub.io/api/v1/search?q=" +
        url_sub +
        "&token=c9guatqad3iblo2fo3e0";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // print(response.body);
      return CompeletSearch.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}

Future<Stock?> fetchCompStock(String compSymbol) async {
  try {
    //https://finnhub.io/api/v1/quote?symbol=AAPL&token=c9guatqad3iblo2fo3e0

    String url = "https://finnhub.io/api/v1/quote?symbol=" +
        compSymbol +
        "&token=c9guatqad3iblo2fo3e0";
    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        // Time has run out, do what you wanted to do.
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      return Stock.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return null;
      throw Exception('Failed to load');
    }
  } catch (e) {
    // print(e);
    return null;
    throw Exception(e.toString());
  }
}

Future<CompanyDetail?> fetchCompDetail(String compSymbol) async {
  try {
    //https://finnhub.io/api/v1/stock/profile2?symbol=AAPL&token=c9guatqad3iblo2fo3e0
    String url = "https://finnhub.io/api/v1/stock/profile2?symbol=" +
        compSymbol +
        "&token=c9guatqad3iblo2fo3e0";
    final response = await http.get(Uri.parse(url)).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        // Time has run out, do what you wanted to do.
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      // print(response.body);
      return CompanyDetail.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return null;
      throw Exception('Failed to load');
    }
  } catch (e) {
    throw Exception(e.toString());
  }
}


final String asySharedKey = "stock";

addStringToSF(val) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? stringValue = prefs.getString(asySharedKey);

  await prefs.setString(asySharedKey, val);
  // print("updated prefs: " + val);
}

Future<String?> getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String

  // print(prefs.getString(asySharedKey));

  String? stringValue = prefs.getString(asySharedKey);
  if (stringValue == null) {
    throw new FormatException('thrown-error');
  }
  return stringValue;
}

// List<SearchEntry> decode(String musics) {
//   return (json.decode(musics) as List<dynamic>)
//       .map<SearchEntry>((item) => SearchEntry.fromJson(item))
//       .toList();
// }

Future<List<SearchEntry>> decode(String entries) async {
  return (json.decode(entries) as List<dynamic>)
      .map<SearchEntry>((item) => SearchEntry.fromJson(item))
      .toList();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Future<List<SearchEntry>> _getSharedPref() async {
  //
  //   String? stockEntryString = await getStringValuesSF();
  //   // print(stockEntryString);
  //   favlists = await decode(stockEntryString!);
  //   return favlists;
  //
  // }
  late Future<List<SearchEntry>> Fu;

  Future<List<SearchEntry>> _getSharedPref() async {
    String? stockEntryString = await getStringValuesSF();
    // print("get=" + stockEntryString!);
    Fu = decode(stockEntryString!); // updates our global favlists gives s list
    return Fu;
  }

  // here our list of fav is the Fu

  void updateFavListInMem(String newEncFavList) async {
    addStringToSF(newEncFavList); //send back to memory
  }

  void removeEntryFromFavList(List<SearchEntry> list, String symbol) {
    int index = list.indexWhere((element) => element.displaySymbol == symbol);
    // print(index);
    // print(list[index]);
    list.removeAt(index);
  }

  @override
  void initState() {
    super.initState();
    Fu = _getSharedPref(); // reset
    // loadSharedPref();
    // _loadFav();
    // Fetch and decode data
  }

  void update() {
    setState(() {
      Fu = _getSharedPref();

      // _loadFav();
    });
  }

  var now = new DateTime.now();
  var formatter = new DateFormat.MMMMd('en_US');

  // final now = new DateTime.now();
  // String formatter =  .format(now);
  @override
  Widget build(BuildContext context) {
    // var curData = InheritedDataProvider.of(context).data;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Stock'),
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(),
                    // Pass the arguments as part of the RouteSettings. The
                    // DetailScreen reads the arguments from these settings.
                    // settings: RouteSettings(
                    //   arguments: compList[index],
                    // ),
                  ),
                ).then((value) {
                  update();
                });
                ;
              },
              icon: Icon(Icons.search),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            top: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            // padding: const EdgeInsets.all(16.0),

            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Text("STOCK WATCH",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: Text(formatter.format(now),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold))),
                ],
              ),
              SizedBox(height: 20),

              Text("Favorites", style: TextStyle(fontSize: 20)),
              SizedBox(height: 20),


              Divider(thickness: 2, color: Colors.white),
              SizedBox(height: 20),

              // favlists.length == 0? Text("FAVES") : renderFavList(favlists),
              FutureBuilder(
                future: Fu,
                builder: (context, snapshot) {
                  // Checking if future is resolved or not

                  if (snapshot.connectionState == ConnectionState.done) {
                    // If we got an error

                    if (Fu == null  ) {
                      return Center(
                        child: Text("Empty",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                      );
                      // if we got our data
                    } else if (snapshot.hasData) {
                      final data = snapshot.data as List<SearchEntry>;
                      if (data.length == 0  ) {
                        return Center(
                          child: Text("Empty",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold)),
                        );
                        // if we got our data
                      }
                      // Extracting data from snapshot object
                      return Expanded(
                        child: ListView.separated(
                            scrollDirection: Axis.vertical,
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              // data.add(data.last); /*4*/

                              // if (i.isOdd) {
                              //   return const Divider(
                              //     thickness: 2,
                              //     color: Colors.white,
                              //   );
                              //   /*2*/
                              // }
                              // final index = i ~/ 2; /*3*/
                              final index = i; /*3*/
                              // print(index);
                              // print(i);
                              // print(data.length);

                              final item = data[index];

                              return Dismissible(
                                // Each Dismissible must contain a Key. Keys allow Flutter to
                                // uniquely identify widgets.
                                key: Key(item.displaySymbol),
                                background: Container(
                                  color: Colors.red,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(Icons.delete, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),

                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Delete Confirm"),
                                        content: const Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                              },
                                              child: const Text("Delete")),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    },
                                  );;
                                },
                                // Provide a function that tells the app
                                // what to do after an item has been swiped away.
                                onDismissed: (direction) {
                                  // Remove the item from the data source.
                                  setState(() {
                                    removeEntryFromFavList(data,
                                        item.displaySymbol); // now the list is data, and we remove the item at the targeted symbol

                                    // update in memery storey
                                    final String encodedData =
                                        SearchEntry.encode(data);
                                    // print("line 460" + encodedData);
                                    // print("\n");
                                    updateFavListInMem(encodedData);
                                    update();

                                    // now trigger rebuild, with new Fu = new list of item in mem
                                  });
                                },

                                // Show a red background as the item is swiped away.
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StockDetail(
                                            entryDetail: data[index],
                                          ),
                                          // Pass the arguments as part of the RouteSettings. The
                                          // DetailScreen reads the arguments from these settings.
                                          // settings: RouteSettings(
                                          //   arguments: compList[index],
                                          // ),
                                        ),
                                      ).then((value) {
                                        update();
                                      });
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            17, 7, 7.0, 7.0),
                                        child: Column(children: <Widget>[
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child:
                                                Text(data[index].displaySymbol),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(data[index]
                                                    .description
                                                    .substring(0, 1) +
                                                data[index]
                                                    .description
                                                    .substring(1)
                                                    .toLowerCase()
                                                    .split('inc')[0] +
                                                "Inc"),
                                          ),
                                        ]))),
                              );
                            },
                            separatorBuilder: (context, index){
                              return const Divider(
                                      thickness: 2,
                                      color: Colors.white,
                                    );/* Your separator widget here */;
                            }
                        ),
                      );
                    }
                    else  {
                      return Column(children: const <Widget>[
                        SizedBox(height: 10),
                        Center(
                          child: Text("Empty",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold)),
                        ),
                      ]);
                    }
                  }

                  // Displaying LoadingSpinner to indicate waiting state
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ));
  }
}

Future<List<SearchEntry>> getFavList() async {
  String? encode_str = await getStringValuesSF();
  List<SearchEntry> favlists = await decode(encode_str!);
  return favlists;
}

Widget _builContent(List<SearchEntry> searchEntries) {
  // CompanyDetail compD = compList[index];

  return ListView.builder(
    itemCount: searchEntries.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(searchEntries[index].displaySymbol +
            " | " +
            searchEntries[index].description),
        // When a user taps the ListTile, navigate to the DetailScreen.
        // Notice that you're not only creating a DetailScreen, you're
        // also passing the current
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetail(
                entryDetail: searchEntries[index],
              ),
              // Pass the arguments as part of the RouteSettings. The
              // DetailScreen reads the arguments from these settings.
              // settings: RouteSettings(
              //   arguments: compList[index],
              // ),
            ),
          );
        },
      );
    },
  );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final myController = TextEditingController();

  List<SearchEntry> searchEntries = [];
  // StreamController<List<SearchEntry>> _searchEntryStream;

  void sendSearchResults(String query) {
    // print(query);
    fetchSearchList(query).then((result) {
      // Once we receive our name we trigger rebuild.
      setState(() {
        searchEntries = result.listOfRes;
      });
    });
    // _searchEntryStream.add(searchEntries);

    // print(futureAlbum);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Center(
            child: TextField(
              onChanged: (value) {
                sendSearchResults(value);
              },
              controller: myController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    myController.clear();
                  },
                ),
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body:
      searchEntries.isEmpty
          ? Center(
              child:
                  Text('No suggestions Found!', style: TextStyle(fontSize: 22)))
          : _builContent(searchEntries),
    );
  }
}

class StockDetail extends StatefulWidget {
  final SearchEntry entryDetail;

  const StockDetail({Key? key, required this.entryDetail}) : super(key: key);

  @override
  _StockDetailState createState() => _StockDetailState();
}

class _StockDetailState extends State<StockDetail> {
  String url =
      "https://finnhub.io/api/v1/quote?symbol=symbol&token=c9guatqad3iblo2fo3e0";

  late CompanyDetail compDetail; // fetched object in future
  late Stock stockDetail; //fetched future object i
  late InforPage info; // load with future

  bool isInFavList = false;
  List<SearchEntry> favList = []; // get the list of fav lists

  /* Method for load local instance of fav list
   */

  // ().then
/* Method for get isIn
 */
  Future<bool> getIsIn(String tar) async {
    favList = await getFavList();
    bool isIn = false;
    if (favList.length == 0) false;
    for (SearchEntry e in favList) {
      if (e.displaySymbol == tar) {
        // setState(() {
        isIn = true;
        // });
      }
    }
    return isIn;
  }

  @override
  void initState() {
    super.initState();
    String tar = widget.entryDetail.displaySymbol;
    // loadFavList(favList);
    getIsIn(tar).then((value) => setState(() {
          isInFavList = value;
        }));
  }

  void loadFavList(List<SearchEntry> favlists) async {
    favlists = await getFavList();
  }

  void updateFavListInMem(String newEncFavList) async {
    addStringToSF(newEncFavList); //send back to memory
  }

  void removeEntryFromFavList(String symbol) {
    int index =
        favList.indexWhere((element) => element.displaySymbol == symbol);

    // print(index);
    // print(favList[index]);
    favList.removeAt(index);
  }

  // Future
  // update the view when state change
  Future<InforPage?> _getStockInfo(String query) async {
    // getIsIn(widget.entryDetail.displaySymbol).then((value) => setState(() {
    //   isInFavList = value;
    // }));

    Stock? temp_stock = await fetchCompStock(query);
    CompanyDetail? temp_comp = await fetchCompDetail(query);
    if (temp_stock == null || temp_comp == null) {
      throw new FormatException('thrown-error');
    }
    // temp_stock = stockDetail;

    info = InforPage(
      currentPrice: temp_stock.currentPrice,
      dchange: temp_stock.dchange,
      dpercentChange: temp_stock.dpercentChange,
      highPriceOfDay: temp_stock.highPriceOfDay,
      lowPriceOfDay: temp_stock.lowPriceOfDay,
      openPriceOfDay: temp_stock.openPriceOfDay,
      previousClosePrice: temp_stock.previousClosePrice,
      t: temp_stock.t,
      name: temp_comp.name,
      symbol: temp_comp.symbol,
      startDate: temp_comp.startDate,
      industry: temp_comp.industry,
      website: temp_comp.website,
      exchange: temp_comp.exchange,
      marketCap: temp_comp.marketCap,
    );
    // if(isInFavList){
    //   setState(() {
    //     isInFavList = true;
    //   });
    // }

    return info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Details'),
        ),
        leading: BackButton(
          onPressed: () {
            // Navigate back to the first screen by popping the current route
            // off the stack.
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (isInFavList == false) {
                  // List<SearchEntry> favlists = await getFavList();
                  favList.add(widget.entryDetail);
                  isInFavList = true;
                  final snackBar = SnackBar(
                    content: Text(widget.entryDetail.displaySymbol +
                        ' was added to watchlist'),
                    backgroundColor: (Colors.white),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  // List<SearchEntry> favlists = await getFavList();
                  removeEntryFromFavList(widget.entryDetail.displaySymbol);
                  isInFavList = false;
                  final snackBar = SnackBar(
                    content: Text(widget.entryDetail.displaySymbol +
                        ' was removed from watchlist'),
                    backgroundColor: (Colors.white),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                final String encodedData = SearchEntry.encode(favList);
                // print(encodedData);
                // print("\n");
                updateFavListInMem(encodedData);
              });
            },
            icon: isInFavList ? Icon(Icons.star) : Icon(Icons.star_border),
          ),
        ],
      ),
      // body: stockDetail.checknullValue() ? Center(child: Text('Failed to Fetch Stock Data'))
      //     : _buildContext(stockDetail, compDetail), // for each stock/Company render the view
      body: FutureBuilder(
        future: _getStockInfo(widget.entryDetail.displaySymbol),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return Center(
                child: Text("Failed to Fetch Stock Data", style: TextStyle(fontSize: 22)),
              );
            }
            if (snapshot.hasData) {
              // Extracting data from snapshot object
              final info = snapshot.data as InforPage;
              var dchangColor = info.dchange > 0.0 ? Colors.green : Colors.red;
              String dchangeSign = info.dchange > 0.0 ? "+" : "";
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // _buildStockContext(info),
                      Row(
                        children: [
                          Text(info.symbol, style: TextStyle(fontSize: 25)),
                          SizedBox(
                            width: 25,
                          ),
                          Text(info.name,
                              style:
                                  TextStyle(fontSize: 25, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(info.currentPrice.toString(),
                              style: TextStyle(fontSize: 25)),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(dchangeSign+ info.dchange.toString(),
                              style:
                                  TextStyle(fontSize: 25, color: dchangColor)),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child:
                                Text("Stats", style: TextStyle(fontSize: 25)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(4),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(4),
                                  },
                                  // textDirection: TextDirection.rtl,
                                  // defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                                  // border:TableBorder.all(width: 2.0,color: Colors.red),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          child: const Align(
                                            alignment: Alignment.center,
                                            child: Text("Open",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                          ),
                                        ),
                                        Container(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                    info.openPriceOfDay
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 18)))),
                                        Container(
                                          child: const Align(
                                              alignment: Alignment.center,
                                              child: Text("High",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 20))),
                                        ),
                                        Container(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  info.highPriceOfDay
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 18),
                                                ))),
                                      ],
                                    )
                                  ]),
                            ],
                          ),
                          Column(
                            children: [
                              Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(4),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(4),
                                  },
                                  // textDirection: TextDirection.rtl,
                                  // defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                                  // border:TableBorder.all(width: 2.0,color: Colors.red),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                            child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Low",
                                            style: TextStyle(fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                        Container(
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                  info.lowPriceOfDay.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 18))),
                                        ),
                                        Container(
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Prev",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 20),
                                              )),
                                        ),
                                        Container(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                                info.previousClosePrice
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 18)),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),

                      Column(
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Text("About",
                                  style: TextStyle(fontSize: 25))),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 120.0,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Start Date",
                                        style: TextStyle(fontSize: 14))),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(info.startDate,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey))),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  width: 120.0,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text("Industry",
                                          style: TextStyle(fontSize: 14)))),
                              const SizedBox(
                                width: 20,
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(info.industry,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey))),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  width: 120.0,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text("Website",
                                          style: TextStyle(fontSize: 14)))),
                              const SizedBox(
                                width: 20,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: InkWell(
                                    child: Text(info.website,
                                        style: TextStyle(
                                            fontSize: 14,
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.blue)),
                                    onTap: () =>
                                        launchUrl(Uri.parse(info.website))),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 120.0,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Exchange",
                                        style: TextStyle(fontSize: 14))),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(info.exchange,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)))
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 120.0,
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Market Cap",
                                        style: TextStyle(fontSize: 14))),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(info.marketCap.toString(),
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey))),
                            ],
                          ),
                        ],
                      ),
                    ]),
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
