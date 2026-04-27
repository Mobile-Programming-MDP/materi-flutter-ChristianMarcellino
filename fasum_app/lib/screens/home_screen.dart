import 'package:fasum_app/screens/add_post_screen.dart';
import 'package:fasum_app/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _signout() async {
    await FirebaseAuth.instance.signOut();
    if(!mounted){
      return;
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInScreen(),), (route) => false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cepu App"),
        actions: [
          IconButton(onPressed: (){_signout();}, icon: Icon(Icons.logout), tooltip: "Sign Out",)
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Text("Hello ${FirebaseAuth.instance.currentUser?.displayName}"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        showDialog(context: context, builder: (context) {
          return const AddPostScreen();
        },);
      }, child: Icon(Icons.add),
    ));
  }
}