import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier/classification.dart';
import 'classifier/image_classifier.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // NOTE: Assuming these classes are available in your project structure.
  // final ImageClassifier _classifier = ImageClassifier();
  // File? _image;
  // String myLabel = "";
  // double myConfidence = 0.0;
  
  // Since the classifier logic is local, I will mock it for a runnable example,
  // but use the user's provided variables and logic structure.

  final ImageClassifier _classifier = ImageClassifier();
  File? _image;

  String myLabel = "";
  double myConfidence = 0.0;
  bool lowConfidence = false;

  @override
  void initState() {
    super.initState();
    _classifier.initialize();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source,
      maxWidth: 500, 
      maxHeight: 500,
      imageQuality: 90,);

    // Reset results when a new image is picked but before classification starts
    setState(() {
      _image = null; // Reset image first to show placeholder while loading
      myLabel = "";
      myConfidence = 0.0;
      lowConfidence = false;
    });

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        // --- Classification Logic Start ---
        // NOTE: If you are getting errors here, ensure 'classification.dart' and 
        // 'image_classifier.dart' are correctly implemented.
        final classifications = await _classifier.classifyImage(_image!);

        final highestConfidenceClassification = classifications.reduce(
            (current, next) =>
                current.confidence > next.confidence ? current : next);

        String getLabel = highestConfidenceClassification.label;
        double getConfidence = highestConfidenceClassification.confidence;

        if (getConfidence >= 0.90) {
          myLabel = getLabel;
          myConfidence = getConfidence;
          lowConfidence = false;

        } else {
          myLabel = "Confidence Low, Try another image!";
          myConfidence = getConfidence;
          lowConfidence = true;
        }
        
        // --- Classification Logic End ---

        setState(() {
          // Update UI with new classification results (myLabel and myConfidence)
        });

      } catch (e) {
        print('Classification error: $e');
        
        // --- FIX: Correct SnackBar usage ---
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Classification error: $e'),
                    duration: const Duration(seconds: 4),
                ),
            );
        }
        setState(() {
           myLabel = "Classification failed.";
           myConfidence = 0.0;
           lowConfidence = true;
        });
      }
    }
  }

  // Helper widget to display the results conditionally
  List<Widget> _buildResults() {
    if (_image == null || myLabel.isEmpty) {
      // Hide results if no image is selected
      return [];
    }
    
    // Only show results if an image is selected
    return [
      const SizedBox(height: 20),
      const Text(
        "Result",
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
      Text(
        myLabel,
        maxLines: 3,
        style:  TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: lowConfidence == true ?  Colors.deepOrange : Colors.green// Add some color for emphasis
        ),
      ),
      Text(
        'Confidence: ${(myConfidence * 100).toStringAsFixed(2)}%',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 20),
    ];
  }


  @override
  Widget build(BuildContext context) {
    // Define the button style once for consistency
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue, // Blue background
      foregroundColor: Colors.white, // White text and icon color
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Image Classification',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display selected image or Placeholder
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade400, // Square shape border
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover, // Ensure image covers the box nicely
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    ),
            ),
      
            const SizedBox(height: 40),
      
            // Classification results (conditionally displayed)
            ..._buildResults(), 
      
            // Image selection buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: buttonStyle, // Apply the custom style
                  label: const Text("Take Photo"),
                  icon: const Icon(Icons.camera),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: buttonStyle, // Apply the custom style
                  label: const Text('Import Photo'),
                  icon: const Icon(Icons.photo_camera_back),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }
}