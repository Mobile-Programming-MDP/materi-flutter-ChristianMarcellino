import 'package:fasum_app/screens/add_post_screen.dart';
import 'package:fasum_app/screens/sign_in_screen.dart';
import 'package:fasum_app/services/fasum_service.dart';
import 'package:fasum_app/widgets/post_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }
  String? _selectedCategory = "All";
  List<String> categories = [
    "All",
    "Jalan Rusak",
    "Lampu Jalan Mati",
    "Lawan Arah",
    "Merokok di Jalan",
    "Tidak Pakai Helm",
  ];


  //Fungsi untuk membuat url foto profile / avatar
  String generateAvatarUrl(String? fullName) {
    final formattedName = fullName!.trim().replaceAll(' ', '+');
    return 'https://ui-avatars.com/api/?name=$formattedName&color=FFFFFF&background=000000';
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: categories.map((cat) {
            return ListTile(
              title: Text(cat),
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () {
              signOut();
            },
            icon: Icon(Icons.logout),
            tooltip: "Sign Out",
          ),
          IconButton(
            onPressed: () {
              _showCategorySelector();
            },
            icon: Icon(Icons.filter),
            tooltip: "Filter",
          )
          
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8.0),
          Image.network(
            generateAvatarUrl(
              FirebaseAuth.instance.currentUser?.displayName.toString(),
            ),
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 8.0),
          Text(
            FirebaseAuth.instance.currentUser!.displayName!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Divider(),
          Expanded(
            child: StreamBuilder(
              stream:FasumService.getPostByCategory(_selectedCategory!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final posts = snapshot.data ?? [];
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts yet.'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final isOwner =
                          currentUserId != null &&
                          post.userId == currentUserId;
                      return PostListItem(post: post, isOwner: isOwner);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}