import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:food/utils/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderStatisticsPage extends StatefulWidget {
  @override
  _OrderStatisticsPageState createState() => _OrderStatisticsPageState();
}

class _OrderStatisticsPageState extends State<OrderStatisticsPage> {
  List<Map<String, dynamic>> orders = [];
  double totalExpenditure = 0;
  int orderCount = 0;
  Map<String, int> itemFrequency = {};
  List<ExpenditureData> expenditureData = [];
  Map<int, String> indexToDay = {};
  TextEditingController _budgetController = TextEditingController();
  double budget = 0.0; // Store the budget
  bool budgetExceeded = false; // Flag to track if budget is exceeded
  bool isAscending = false;



  @override
  void initState() {
    super.initState();
    fetchOrders();
    _loadBudget();
  }

  double calculateTrimmedMean(List<double> values, double trimPercent) {
    if (values.isEmpty) return 0;

    values.sort();
    int trimCount = (values.length * trimPercent).toInt();

    List<double> trimmed = values.sublist(trimCount, values.length - trimCount);
    return trimmed.reduce((a, b) => a + b) / trimmed.length;
  }



  // Function to load saved budget from Firestore or local storage
  Future<void> _loadBudget() async {
    try {
      // Here, you can fetch the budget from Firestore or local storage
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') // assuming you have a 'users' collection
          .doc('user_id') // Use the current user's ID
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          budget = snapshot['budget'] ?? 0.0;
          _budgetController.text = budget.toString();
        });
      }
    } catch (e) {
      print("Error loading budget: $e");
    }
  }

  // Function to save budget to Firestore or local storage
  Future<void> _saveBudget() async {
    double inputBudget = double.tryParse(_budgetController.text) ?? 0.0;

    try {
      // Save the budget to Firestore or local storage
      await FirebaseFirestore.instance
          .collection('users')
          .doc('user_id') // Use the current user's ID
          .set({
        'budget': inputBudget,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other data

      setState(() {
        budget = inputBudget;
      });
    } catch (e) {
      print("Error saving budget: $e");
    }
  }

// Function to compare budget with total expenditure and update the budget status
  void _compareBudget() {
    setState(() {
      budgetExceeded = totalExpenditure > budget;
    });
  }

// Function to calculate remaining budget
  double get remainingBudget => budget - totalExpenditure;

// Function to fetch orders and update total expenditure
  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String fullEmail = prefs.getString('id') ?? "example@email.com";
      String userEmail = fullEmail.split('@')[0]; // match document ID

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user_orders')
          .doc(userEmail)
          .collection('orders')
          .get();

      double expenditure = 0;
      int count = 0;
      Map<String, int> tempItemFrequency = {};
      List<ExpenditureData> tempExpenditureData = [];

      DateTime now = DateTime.now();

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('totalAmount') && data.containsKey('orderDate')) {
          Timestamp timestamp = data['orderDate'];
          DateTime orderDate = timestamp.toDate();

          if (orderDate.month == now.month && orderDate.year == now.year) {
            expenditure += (data['totalAmount'] as num).toDouble();
            count++;

            tempExpenditureData.add(ExpenditureData(
              orderDate,
              (data['totalAmount'] as num).toDouble(),
            ));

            List items = data['items'] ?? [];
            for (var item in items) {
              String name = item['productName'];
              int quantity = (item['quantity'] as num).toInt();

              // For debugging
              print('Order Date: $orderDate | Product: $name | Quantity: $quantity');

              tempItemFrequency[name] =
                  (tempItemFrequency[name] ?? 0) + quantity;
            }
          }
        }
      }

      setState(() {
        orders = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        totalExpenditure = expenditure;
        orderCount = count;
        itemFrequency = tempItemFrequency;
        expenditureData = tempExpenditureData;

        _compareBudget();
      });
    } catch (error) {
      print("Error fetching orders: $error");
    }
  }


// Function to set the budget dynamically
  void setBudget(double newBudget) {
    setState(() {
      budget = newBudget;
      // Call _compareBudget whenever budget is updated
      _compareBudget();
    });
  }




  List<BarChartGroupData> _buildBarChartData() {
    final Map<String, double> aggregatedData = {};
    final Map<String, double> dayToIndex = {};
    indexToDay.clear(); // Assuming this is a global or class-level map

    // Step 1: Aggregate amounts by date
    for (var data in expenditureData) {
      String label = "${data.date.day}/${data.date.month}";

      if (aggregatedData.containsKey(label)) {
        aggregatedData[label] = aggregatedData[label]! + data.amount;
      } else {
        aggregatedData[label] = data.amount;
      }
    }

    // Step 2: Map each unique date to an X index
    int i = 0;
    aggregatedData.keys.forEach((label) {
      dayToIndex[label] = i.toDouble();
      indexToDay[i] = label;
      i++;
    });

    // Step 3: Build the grouped chart data
    List<BarChartGroupData> groupData = [];

    aggregatedData.forEach((label, totalAmount) {
      int x = dayToIndex[label]!.toInt();

      groupData.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: totalAmount,
              color: AppColors.themeColor,
              width: 16,
            ),
          ],
        ),
      );
    });

    return groupData;
  }


  List<PieChartSectionData> _buildPieChartData() {
    final List<MapEntry<String, int>> sortedItems = itemFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // sort by quantity descending

    return List.generate(sortedItems.length, (i) {
      final item = sortedItems[i].key;
      final quantity = sortedItems[i].value;
      final color = Colors.primaries[i % Colors.primaries.length];

      return PieChartSectionData(
        color: color,
        value: quantity.toDouble(),
        title: '$quantity', // Label with quantity
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 110, // Bigger chart
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    double trimmedMean = calculateTrimmedMean(expenditureData.map((e) => e.amount).toList(), 0.1);

    // Check if budget is exceeded or safe
    String budgetStatus = budgetExceeded ? "Budget Exceeded" : "Safe";

    String mostOrderedItem = "";
    int maxFrequency = 0;
    itemFrequency.forEach((item, frequency) {
      if (frequency > maxFrequency) {
        maxFrequency = frequency;
        mostOrderedItem = item;
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: AppColors.themeColor, // AppBar color
        title: Text(
          'Order Statistics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: orders.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Monthly Statistics",
              style: TextStyle(
                  color: AppColors.themeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildKpiCard("Total Orders", "$orderCount", AppColors.themeColor, Iconsax.bag_tick),
                _buildKpiCard(
                    "Avg. Expenditure", "Rs. ${trimmedMean.toStringAsFixed(2)}", AppColors.themeColor, CupertinoIcons.money_dollar_circle),
                _buildKpiCard("Most Ordered Item", "$mostOrderedItem ($maxFrequency)",AppColors.themeColor, CupertinoIcons.heart_fill),
              ],
            ),
            SizedBox(height: 30),
            if (expenditureData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Expenditure this Month",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.themeColor),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Set Your Budget",
                    style: TextStyle(
                      color: AppColors.themeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(CupertinoIcons.checkmark_alt_circle_fill, color: AppColors.themeColor),
                        onPressed: () {

                          _saveBudget(); // Save the budget when the user presses save
                          _compareBudget(); // Compare with the total expenditure
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (_buildBarChartData()
                              .map((group) => group.barRods.first.toY)
                              .reduce((a, b) => a > b ? a : b) / 500).ceil() * 500,


                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: AppColors.white, // Change background color
                                tooltipBorder: BorderSide(color: AppColors.themeColor)
                            ),
                            handleBuiltInTouches: true, // Enable touch interactions
                          ),
                          titlesData: FlTitlesData(
                            // Customization for title data if needed
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: 500,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toString(),
                                    style: TextStyle(
                                      fontSize: 10, // 👈 Set your desired font size here
                                    ),
                                  );
                                },
                              ),
                            ),

                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 4.0, // space between label and axis
                                    child: Transform.rotate(
                                      angle: -0.5, // Radians, ~-28 degrees (adjust as needed)
                                      child: Text(
                                        indexToDay[value.toInt()] ?? '',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          barGroups: _buildBarChartData(),
                        )

                    ),
                  ),
                  SizedBox(height: 20,),
                  Text(
                    "Budget Status: $budgetStatus",
                    style: TextStyle(
                      color: budgetExceeded ? Colors.red : Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal:8, vertical: 6),
                    decoration: BoxDecoration(
                      color: budgetExceeded
                          ? Colors.red.withOpacity(0.3)
                          : Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6), // This gives the rounded effect
                    ),
                    child: Text(
                      budgetExceeded
                          ? "You went Rs. ${(totalExpenditure - budget).toStringAsFixed(2)} over the budget"
                          : "Remaining Budget: Rs. ${(budget - totalExpenditure).toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkerGrey,
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 40),
            if (itemFrequency.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Items Ordered This Month",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.themeColor),
                  ),
                  SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 1.4, // Make the chart larger
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartData(),
                        borderData: FlBorderData(show: false),
                        centerSpaceRadius: 0,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),

                  Scrollbar(
                    thumbVisibility: false, // initially hidden
                    trackVisibility: false,
                    interactive: true,
                    child: Scrollbar(
                      thumbVisibility: false,
                      trackVisibility: false,
                      interactive: true,
                      notificationPredicate: (notif) => notif is ScrollUpdateNotification,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 400, // adjust this based on how wide the legend might go
                          child: Scrollbar(
                            thumbVisibility: false,
                            trackVisibility: false,
                            interactive: true,
                            notificationPredicate: (notif) => notif is ScrollUpdateNotification,
                            child: SizedBox(
                              height: 300,
                              child: GridView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: itemFrequency.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 8,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, index) {
                                  final entry = itemFrequency.entries.toList()[index];
                                  final item = entry.key;
                                  final quantity = entry.value;
                                  final color = Colors.primaries[index % Colors.primaries.length];

                                  return Row(
                                    children: [
                                      Container(width: 12, height: 12, color: color),
                                      SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          '$item ($quantity)',
                                          style: TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )



                ],
              ),

          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    double cardWidth = (MediaQuery.of(context).size.width - 48) / 3;
    double cardHeight = 210.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 35, color: Colors.white),
          SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 8),
          Text(value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}

class ExpenditureData {
  final DateTime date;
  final double amount;

  ExpenditureData(this.date, this.amount);
}

class Order {
  final String item;
  final double amount;
  final DateTime date;

  Order({required this.item, required this.amount, required this.date});
}
