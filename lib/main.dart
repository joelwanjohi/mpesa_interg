// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:mpesa_flutter_plugin/initializer.dart';
// import 'package:mpesa_flutter_plugin/payment_enums.dart';

// void main() {
//   MpesaFlutterPlugin.setConsumerKey("719afMTHt3iQVPsTA4vQZqddCnM13kQoEX4wG1kh8WUjXfxD");
//   MpesaFlutterPlugin.setConsumerSecret("YK16wZidhGRioDO06vvEAPEbixzOkYwjeVFc9tt18MbT0THOWkIVBwHKYeF31cuP");

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
      
//        primarySwatch: Colors.green,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});


//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   var number = TextEditingController();

// //method to initiate the transaction 
//   Future<void> startCheckout({required String userPhone, required String amount}) async {
//     dynamic transactionInitialization;

//     try{
//       transactionInitialization =
//       await MpesaFlutterPlugin.initializeMpesaSTKPush(
//         businessShortCode: "174379",
//          transactionType:  TransactionType.CustomerPayBillOnline, 
//          amount: double.parse(amount), 
//          partyA: userPhone, 
//          partyB: "174379", 
//          callBackURL: Uri.parse("https://sandbox.safaricom.co.ke/"),
//          accountReference: "Mpesa Joel", 
//          phoneNumber: userPhone,
//           baseUri: Uri.parse("https://sandbox.safaricom.co.ke/"),
//           passKey: 
//           "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
//           );
//           print("Transaction Result: " + transactionInitialization.toString());
//           return transactionInitialization;
//     } catch (e) {
//       print("Exception: " + e.toString());
//     }
//   }

//   void _showToast(BuildContext context) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: const Text('Sending Request'),
//       duration: Duration(seconds: 2),
//     ),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
   
//    return Scaffold(
//       appBar: AppBar(
//       title: Center(
//         child: Text(
//           'MPESA Pay',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       ),

//       body: Builder(
//         //body now wrapped in a builder
//         builder: (context) => Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget> [
//               SvgPicture.asset('assets/mpesa.svg', width: 150, height: 150),
//               SizedBox(
//                 height: 15.0,
//               ),
//               FloatingActionButton.extended(
//                 backgroundColor: Colors.blueAccent,
//                 icon: Icon(Icons.account_balance_wallet),
//                 label: Text('pay', style: TextStyle(color: Colors.white),),
//                 onPressed: (){
//                   _showToast(context);
//                   startCheckout(
//                     userPhone: "254743864282", amount: '2'
//                   );               
//                   }
//               )
//             ],
//           ),
//         ))// This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:mpesa_flutter_plugin/payment_enums.dart';

void main() {
  MpesaFlutterPlugin.setConsumerKey("719afMTHt3iQVPsTA4vQZqddCnM13kQoEX4wG1kh8WUjXfxD");
  MpesaFlutterPlugin.setConsumerSecret("YK16wZidhGRioDO06vvEAPEbixzOkYwjeVFc9tt18MbT0THOWkIVBwHKYeF31cuP");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M-PESA Payment',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'M-PESA Payment'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> startCheckout({required String userPhone, required String amount}) async {
    dynamic transactionInitialization;
    try {
      transactionInitialization = await MpesaFlutterPlugin.initializeMpesaSTKPush(
        businessShortCode: "174379",
        transactionType: TransactionType.CustomerPayBillOnline,
        amount: double.parse(amount),
        partyA: userPhone,
        partyB: "174379",
        callBackURL: Uri.parse("https://sandbox.safaricom.co.ke/"),
        accountReference: "Mpesa Joel",
        phoneNumber: userPhone,
        baseUri: Uri.parse("https://sandbox.safaricom.co.ke/oauth/v1/generate"),
        passKey: "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
      );
      print("Transaction Result: " + transactionInitialization.toString());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction initiated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      print("Exception: " + e.toString());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'M-PESA Payment',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Replace SVG with Icon
              Icon(
                Icons.payment_rounded,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone no (254XXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!value.startsWith('254') || value.length != 12) {
                    return 'Please enter a valid phone number starting with 254';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (KES)',
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30.0),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Processing payment...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    
                    startCheckout(
                      userPhone: _phoneController.text,
                      amount: _amountController.text,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}