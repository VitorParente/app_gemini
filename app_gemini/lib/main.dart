// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recomendações de Filme 🎬',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2C2C2C),
          border: OutlineInputBorder(),
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      home: const MovieRecommendationScreen(),
    );
  }
}

class MovieRecommendationScreen extends StatefulWidget {
  const MovieRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<MovieRecommendationScreen> createState() =>
      _MovieRecommendationScreenState();
}

class _MovieRecommendationScreenState extends State<MovieRecommendationScreen> {
  final TextEditingController _temaController = TextEditingController();
  String _recommendationResult = '';
  bool _isLoading = false;
  bool _isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) => setState(() => _isListening = false),
    );
  }

  void _listen() async {
    if (!_isListening) {
      if (await _speech.initialize()) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _temaController.text += result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _getMovieRecommendations() async {
    if (_temaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite ou fale o tema.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const String apiKey = 'AIzaSyBjKfh5Ly23rxn0qRB37tOh3qEQRHM_R7E';
      const String apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';

      final String tema = _temaController.text;
      final String prompt = '''
Quero assistir "$tema".

Com base nesse tema, recomende até 3 filmes que combinem com esse tipo de tema. 
Inclua nome do filme, breve sinopse e por que ele é adequado para o tema solicitado. Use uma linguagem leve e acolhedora. 
Pode misturar clássicos e novidades, e variar entre gêneros como comédia, drama, aventura ou romance.
''';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 800,
          },
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String content =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        setState(() => _recommendationResult = content);
      } else {
        setState(
          () =>
              _recommendationResult =
                  'Erro: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      setState(() => _recommendationResult = 'Erro ao conectar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Row(
          children: [
            Image.asset('assets/logo.jpeg', height: 150),
            const SizedBox(width: 10),
            const Text('🎬 Recomendador de Filmes'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Qual o seu tema desejado? 🎭🎬💥❤️😂',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _temaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Digite ou fale seu tema desejado...',
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _listen,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _getMovieRecommendations,
              icon: const Icon(Icons.movie),
              label:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Buscar filmes'),
            ),
            const SizedBox(height: 24),
            if (_recommendationResult.isNotEmpty) ...[
              const Text(
                'Sugestões de Filmes:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _recommendationResult,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _temaController.dispose();
    super.dispose();
  }
}
