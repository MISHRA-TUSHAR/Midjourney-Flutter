import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:midjourney_flutter/features/prompt/services/api_call.dart';

part 'prompt_event.dart';
part 'prompt_state.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  PromptBloc() : super(PromptInitial()) {
    on<PromptInitialEvent>(promptInitialEvent);
    on<PromptEnteredEvent>(promptEnteredEvent);
  }

  FutureOr<void> promptEnteredEvent(
      PromptEnteredEvent event, Emitter<PromptState> emit) async {
    emit(PromptGeneratingImageLoadState());
    Uint8List? bytes = await PromptRepo.generateImage(event.prompt);
    if (bytes != null) {
      emit(PromptGeneratingImageSuccessState(bytes));
    } else {
      emit(PromptGeneratingImageErrorState());
    }
  }

  FutureOr<void> promptInitialEvent(
      PromptInitialEvent event, Emitter<PromptState> emit) async {
    // Determine the platform-specific assets folder path
    String assetsFolderPath = '';
    if (Platform.isAndroid) {
      assetsFolderPath = 'assets';
    } else if (Platform.isIOS) {
      assetsFolderPath = 'Assets.xcassets';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      assetsFolderPath = 'assets';
    }

    // Construct the path to the image  relative to  assets
    String filePath = path.join(assetsFolderPath, 'file.png');

// Debug
    log('File path: $filePath');

    // rootbundle.load() is converted to uin8
    ByteData data = await rootBundle.load(filePath);
    Uint8List bytes = data.buffer.asUint8List();

// Debug
    log('Bytes length: ${bytes.length}');

    emit(PromptGeneratingImageSuccessState(bytes));
  }
}
