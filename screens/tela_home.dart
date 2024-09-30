import 'package:flutter/material.dart';
import 'tela_time_blocks.dart';
import 'tela_login.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor:  Color(0xff413b6b),
      ),
      body: Container(
        color: Color(0xFF1c0b2b),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                Icons.access_time_filled_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 40),


              Text(
                'Gerencie seu Tempo!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),


              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeBlocksPage()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  child: Text('Adicionar Atividade', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black)),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Color(0xff5c65c0),
                ),
              ),
              SizedBox(height: 20),


              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  child: Text('Sair', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black)),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Color(0xff301c41),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
