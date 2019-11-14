import 'dart:async';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'musique.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: Home()
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }
}

class _Home extends State<Home> {
  int nb = 0;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  Musique maMusiqueActuelle;
  AudioPlayer audioPlayer;
  StreamSubscription stateSubscription;
  StreamSubscription positionSub;
  PlayerState statut = PlayerState.stopped;

  List<Musique> maListeDeMusiques = [
    new Musique("Theme Swift", "Moi", "assets/un.jpg", "https://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    new Musique("Theme Flutter", "Toujours moi", "assets/deux.jpg", "https://codabee.com/wp-content/uploads/2018/06/deux.mp3")
  ];

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[nb];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return  new Scaffold(
      appBar: new AppBar(
        title:  const Text('MUSIC APP'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget> [
              displayInfoMusic(maMusiqueActuelle),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                  bouton((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 45.0, (statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
                  bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  textAvecStyle(fromDuration(position), 0.8),
                  textAvecStyle(fromDuration(duree), 0.8)
                ],
              ),
              new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: duree.inSeconds.toDouble(),
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    audioPlayer.seek(d);
                  });
                },
              )
            ]
        ),
      ),
      backgroundColor: Colors.grey.shade700,
    );
  }

  Widget displayInfoMusic(Musique musique) {
    return new Center(
        child: new Column(
          children: <Widget>[
            new Card(
              child: new Container(
                child: getCoverImage(musique.imagePath),
                width: MediaQuery.of(context).size.width / 1.3,
                height: MediaQuery.of(context).size.width / 1.3,
              ),
              elevation: 15.0,
              margin: EdgeInsets.only(top: 50.0, bottom: 30.0),
            ),
            FittedBox(fit:BoxFit.fitWidth,
                child: textAvecStyle(musique.titre, 1.5)
            ),
            textAvecStyle(musique.artiste, 1.0)
          ],
        )
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
        icon: new Icon(icone),
        color: Colors.white,
        iconSize: taille,
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              pause();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
            case ActionMusic.forward:
              forward();
              break;
          }
        });
  }

  Text textAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
            (pos) => setState(() => position = pos )
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('erreur: $message');
      setState(() {
        statut = PlayerState.stopped;
        position = new Duration(seconds: 0);
        duree = new Duration(seconds: 0);
      });
    });
  }

  Widget getCoverImage(String str) {
    return new Image.asset(str,
      fit: BoxFit.cover,);
  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward(){
    nb++;
    maMusiqueActuelle = maListeDeMusiques[nb % maListeDeMusiques.length];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind(){
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else {
      nb--;
      maMusiqueActuelle = maListeDeMusiques[nb % maListeDeMusiques.length];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }
  
  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused
}