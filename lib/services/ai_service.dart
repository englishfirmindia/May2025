import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AiService {
  final String? apiKey;

  AiService({this.apiKey}) {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('API Key is not initialized');
    }
  }

  Future<String> getAIResponse(String userInput) async {
    const String model = "gpt-4o-search-preview";
    final String url = "https://api.openai.com/v1/chat/completions";
    final user = FirebaseAuth.instance.currentUser;
    String userName = 'User';

  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      userName = doc.data()?['name'] ?? user.email ?? 'User';
    } else {
      userName = user.email ?? 'User';
    }
  }
   

    final Map<String, dynamic> requestBody = {
    "model": model,
    "web_search_options": {
      "user_location": {
        "type": "approximate",
        "approximate": {
          "country": "AU",
          "city": "Parramatta",
          "region": "New South Wales"
        }
      }
    },
    "messages": [
      {
        "role": "system",
        "content": """
You are an AI assistant created by the Englishfirm AI team to help students prepare for the PTE exam.
If a user's question is unrelated to the PTE or Englishfirm services, do not attempt to answer it. Instead, reply exactly with: $userName, please ask questions related to the PTE or Englishfirm services.
Do not provide responses on general topics or questions outside the PTE domain.
Your responses must always be:
a) Clear, concise, and strictly focused on PTE-related topics or Englishfirm services.
b) If the user's question is about any PTE institution, respond only with relevant information about Englishfirm and avoid mentioning other institutions.
"""      },
      {
        "role": "user",
        "content": userInput
      }
    ]
  };


    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String aiResponse = data["choices"][0]["message"]["content"];
        aiResponse = aiResponse.replaceAll(RegExp(r'[*#]'), '');
        return aiResponse;
      } else {
        
        return "$userName I'm having trouble understanding your request. Please try again shortly.";
      }
    } catch (e) {
      
      return "Sorry, $userName something went wrong while processing your request. Please try again in a moment.";
    }
  }
}