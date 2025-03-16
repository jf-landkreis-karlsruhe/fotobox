import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotobox_frontend/src/home_view.dart';
import 'package:fotobox_frontend/src/manager/session_manager.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:watch_it/watch_it.dart';
import 'package:fotobox_frontend/src/service/button_box_service.dart';

class QrView extends StatefulWidget {
  const QrView({super.key});

  static const routeName = '/qrview';

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  var focusNode = FocusNode();
  var controller = CountDownController();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant QrView oldWidget) {
    focusNode.requestFocus();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    focusNode.requestFocus();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final SessionManager manager = di<SessionManager>();

    final ButtonBoxService buttonBoxService = di<ButtonBoxService>();
    buttonBoxService.currentScreen('qr_view');

    return Scaffold(
      body: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (value) {
          switch (value.logicalKey) {
            case LogicalKeyboardKey.space:
              controller.restart();
              break;
            case LogicalKeyboardKey.keyX:
              Navigator.of(context).pushNamed(HomeView.routeName);
              break;
            default:
          }
        },
        child: ValueListenableBuilder(
          valueListenable: manager.saveCurrentSessionCommand,
          builder: (context, sessionLink, _) {
            focusNode.requestFocus();

            return ValueListenableBuilder(
              valueListenable: manager.saveCurrentSessionCommand.isExecuting,
              builder: (context, isRunning, _) {
                if (isRunning) {
                  return const Center(child: CircularProgressIndicator());
                }

                focusNode.requestFocus();

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Column(
                      children: [
                        Expanded(
                          child: sessionLink == null
                              ? const Center(
                                  child: Text(
                                    'Error while saving images!',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Expanded(
                                      child: PrettyQrView.data(
                                        data: sessionLink,
                                        errorCorrectLevel:
                                            QrErrorCorrectLevel.H,
                                        decoration: const PrettyQrDecoration(
                                          shape: PrettyQrSmoothSymbol(
                                            color: Colors.blue,
                                          ),
                                          image: PrettyQrDecorationImage(
                                            image: AssetImage(
                                                'assets/images/Elefant_ohneFlaeche.png'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('Session Link: $sessionLink'),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(HomeView.routeName);
                              },
                              icon: const Icon(
                                Icons.close,
                                size: 50,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                controller.restart();
                              },
                              icon: const Icon(
                                Icons.restart_alt,
                                size: 50,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircularCountDownTimer(
                              controller: controller,
                              duration: 30,
                              width: 50,
                              height: 50,
                              fillColor: Colors.red,
                              backgroundColor: Colors.blue,
                              ringColor: Colors.yellow,
                              autoStart: true,
                              isReverse: true,
                              isTimerTextShown: true,
                              onComplete: () {
                                Navigator.of(context)
                                    .pushNamed(HomeView.routeName);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
