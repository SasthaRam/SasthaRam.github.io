import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),

      /// Add routes
      routes: {
        '/SignUp': (context) => const SignUpPage(),
        '/Login': (context) => const LoginPage(),
      },
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: ElevatedButton(
            child: Text("Go to sign up page"),
            onPressed: () {
              Navigator.pushNamed(context, '/SignUp');
            }),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up Page"),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
              child: Text("Go back"),
              onPressed: () {
                Navigator.pop(context);
              }),

          SizedBox(height: 20),

          ElevatedButton(
              child: Text("Go to login page"),
              onPressed: () {
                Navigator.pushNamed(context, '/Login');
              }),
        ],
      )),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
              child: Text("Go back"),
              onPressed: () {
                Navigator.pop(context);
              }),

          SizedBox(height: 20),

          ElevatedButton(
              child: Text("Go to home page"),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }),
        ],
      )),
    );
  }
}