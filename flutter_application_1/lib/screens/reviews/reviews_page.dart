import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final SupabaseClient _client = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  int _rating = 5;
  bool _isLoading = false;

  late Future<List<Map<String, dynamic>>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _loadReviews() {
    _futureReviews = _client
        .from('reviews')
        .select()
        .order('created_at', ascending: false)
        .then((value) => List<Map<String, dynamic>>.from(value));
  }


  Future<void> _submitReview() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final comment = _commentController.text.trim();

    if (name.isEmpty || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your name and comment"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _client.from('reviews').insert({
        'user_name': name,
        'rating': _rating,
        'comment': comment,
      });


      _nameController.clear();
      _commentController.clear();

      setState(() {
        _rating = 5;
        _loadReviews();
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Review submitted ⭐"),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {

      debugPrint("Review Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }


    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _refresh() async {

    setState(() {
      _loadReviews();
    });

    await _futureReviews;
  }



  // User review দেওয়ার সময় star select
  Widget _buildStarsInput() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {

        return IconButton(
          onPressed: () {

            setState(() {
              _rating = i + 1;
            });

          },

          icon: Icon(
            i < _rating
                ? Icons.star
                : Icons.star_border,

            color: Colors.orange,
          ),
        );

      }),
    );
  }



  // Review show করার star
  Widget _buildStars(int rating) {

    return Row(
      children: List.generate(5, (i) {

        return Icon(

          i < rating
              ? Icons.star
              : Icons.star_border,

          color: Colors.orange,
          size: 16,
        );

      }),
    );
  }



  @override
  Widget build(BuildContext context) {

    return RefreshIndicator(

      onRefresh: _refresh,

      child: ListView(

        padding: const EdgeInsets.all(12),

        children: [


          Card(

            elevation: 3,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),


            child: Padding(

              padding: const EdgeInsets.all(12),

              child: Column(

                children: [


                  const Text(
                    "Write a Review ⭐",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  const SizedBox(height: 10),



                  TextField(

                    controller: _nameController,

                    decoration: const InputDecoration(

                      labelText: "Name",

                      border: OutlineInputBorder(),

                    ),

                  ),



                  const SizedBox(height: 10),



                  _buildStarsInput(),



                  const SizedBox(height: 10),



                  TextField(

                    controller: _commentController,

                    maxLines: 3,


                    decoration: const InputDecoration(

                      labelText: "Comment",

                      border: OutlineInputBorder(),

                    ),

                  ),



                  const SizedBox(height: 10),



                  SizedBox(

                    width: double.infinity,


                    child: ElevatedButton(

                      onPressed: _isLoading
                          ? null
                          : _submitReview,


                      child: _isLoading

                          ? const SizedBox(

                              height: 18,

                              width: 18,

                              child: CircularProgressIndicator(

                                strokeWidth: 2,

                                color: Colors.white,

                              ),

                            )


                          : const Text("Submit"),

                    ),

                  ),


                ],

              ),

            ),

          ),



          const SizedBox(height: 15),



          const Text(

            "All Reviews",

            style: TextStyle(

              fontSize: 18,

              fontWeight: FontWeight.bold,

            ),

          ),



          const SizedBox(height: 10),




          FutureBuilder<List<Map<String, dynamic>>>(


            future: _futureReviews,


            builder: (context, snapshot) {



              if (snapshot.connectionState ==
                  ConnectionState.waiting) {

                return const Center(

                  child: CircularProgressIndicator(),

                );

              }



              if (snapshot.hasError) {

                return const Center(

                  child: Text(
                    "Failed to load reviews",
                  ),

                );

              }



              final data = snapshot.data ?? [];



              if (data.isEmpty) {

                return const Center(

                  child: Text(
                    "No reviews yet ⭐",
                  ),

                );

              }



              return Column(


                children: data.map((r) {



                  final rating =
                      (r['rating'] as num?)
                          ?.toInt() ??
                      0;



                  final name =
                      r['user_name']
                          ?.toString() ??
                      "?";



                  return Card(

                    margin:
                        const EdgeInsets.only(bottom: 10),


                    child: ListTile(


                      leading: CircleAvatar(

                        child: Text(

                          name.isNotEmpty

                              ? name[0]
                                  .toUpperCase()

                              : "?",

                        ),

                      ),



                      title: Text(

                        name,

                        style: const TextStyle(

                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),



                      subtitle: Column(


                        crossAxisAlignment:
                            CrossAxisAlignment.start,


                        children: [


                          const SizedBox(height: 4),


                          _buildStars(rating),


                          const SizedBox(height: 4),


                          Text(

                            r['comment']
                                    ?.toString() ??
                                "",

                          ),


                        ],


                      ),


                    ),


                  );



                }).toList(),


              );

            },


          ),


        ],

      ),

    );

  }

}