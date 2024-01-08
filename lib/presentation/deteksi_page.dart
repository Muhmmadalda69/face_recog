import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'package:quiver/collection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../deketsi_modul/detector.dart';
import '../deketsi_modul/model.dart';
import '../deketsi_modul/utils.dart';

class DeteksiWajahView extends StatefulWidget {
  // ignore: use_super_parameters
  const DeteksiWajahView({Key? key}) : super(key: key);

  @override
  State<DeteksiWajahView> createState() => _DeteksiWajahViewState();
}

class _DeteksiWajahViewState extends State<DeteksiWajahView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _start();
  }

  void _start() async {
    interpreter = await loadModel();
    try {
      initialCamera();
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void disposeCamera() async {
    if (_camera != null) {
      try {
        if (_camera!.value.isStreamingImages) {
          await _camera!.stopImageStream();
        }
        await _camera!.dispose();
      } catch (e) {
        print("Error disposing camera: $e");
      }
      _camera = null;
    }
  }

  @override
  void dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    disposeCamera();
    super.dispose();
  }

  late File jsonFile;
  // ignore: prefer_typing_uninitialized_variables
  var interpreter;
  CameraController? _camera;
  dynamic data = {};
  bool _isDetecting = false;
  double threshold = 1.0;
  dynamic _scanResults;
  String _predRes = '';
  bool isStream = true;
  // ignore: unused_field
  CameraImage? _cameraimage;
  Directory? tempDir;
  // ignore: unused_field
  bool _faceFound = false;
  bool _verify = false;
  List? e1;
  bool loading = true;
  final TextEditingController _name = TextEditingController(text: '');

  void initialCamera() async {
    CameraDescription description =
        await getCamera(CameraLensDirection.front); //camera depan;

    _camera = CameraController(
      description,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _camera!.initialize();

    await Future.delayed(const Duration(milliseconds: 500));
    loading = false;
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    jsonFile = File(_embPath);
    if (jsonFile.existsSync()) {
      data = json.decode(jsonFile.readAsStringSync());
    }

    // await Future.delayed(const Duration(milliseconds: 500));

    _camera!.startImageStream((CameraImage image) async {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        dynamic finalResult = Multimap<String, Face>();

        detect(image, getDetectionMethod()).then((dynamic result) async {
          if (result.length == 0 || result == null) {
            _faceFound = false;
            _predRes = 'Tidak dikenali';
          } else {
            _faceFound = true;
          }

          String res;
          Face _face;

          imglib.Image convertedImage =
              convertCameraImage(image, CameraLensDirection.front);

          for (_face in result) {
            double x, y, w, h;
            x = (_face.boundingBox.left - 10);
            y = (_face.boundingBox.top - 10);
            w = (_face.boundingBox.width + 10);
            h = (_face.boundingBox.height + 10);
            imglib.Image croppedImage = imglib.copyCrop(
                convertedImage, x.round(), y.round(), w.round(), h.round());
            croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
            res = recog(croppedImage);
            finalResult.add(res, _face);
          }

          _scanResults = finalResult;
          _isDetecting = false;
          setState(() {});
        }).catchError(
          (_) async {
            print({'error': _.toString()});
            _isDetecting = false;
            if (_camera != null) {
              await Future.delayed(const Duration(milliseconds: 400));
              if (_camera != null) {
                await _camera!.dispose();
              }
              await Future.delayed(const Duration(milliseconds: 400));
              _camera = null;
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      }
    });
  }

  String recog(imglib.Image img) {
    if (_camera != null) {
      List input = imageToByteListFloat32(img, 112, 128, 128);
      input = input.reshape([1, 112, 112, 3]);
      List output =
          List.filled(1 * 192, null, growable: false).reshape([1, 192]);
      interpreter.run(input, output);
      output = output.reshape([192]);
      e1 = List.from(output);
      return compare(e1!).toUpperCase();
    } else {
      print('CameraController is disposed.');
      return 'Tidak dikenali';
    }
  }

  String compare(List currEmb) {
    //mengembalikan nama pemilik akun
    double minDist = 999;
    double currDist = 0.0;
    _predRes = "Tidak dikenali";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        _predRes = label;
        if (_verify == false) {
          _verify = true;
        }
      }
    }
    return _predRes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Deteksi Wajah",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Builder(builder: (context) {
        if ((_camera == null || !_camera!.value.isInitialized) || loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints.expand(),
          padding: EdgeInsets.only(
              top: 0, bottom: MediaQuery.of(context).size.height * 0.2),
          child: _camera == null
              ? const Center(child: SizedBox())
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(_camera!),
                    _buildResults(),
                  ],
                ),
        );
      }),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Container(
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "MASUKAN NAMA: ",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: _name,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              data[_name.text] = e1;
                              jsonFile.writeAsStringSync(json.encode(data));
                            },
                            child: const Text("Simpan"),
                          )
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }

  Widget _buildResults() {
    Center noResultsText = const Center(
        child: Text('Mohon Tunggu ..',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.blueAccent)));
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }
}
