import controlP5.*;
import fullscreen.*;
import processing.net.*;

final int maxclients = 30;
final int port = 50249;

FullScreen fs;
ControlP5 cp5;

Server server;

Client clients [];
int connectedClients;

color clientDrawColors [];

void setup () {
  size(600, 600);
  
  fs = new FullScreen(this);
  cp5 = new ControlP5(this);
  
  clients = new Client[maxclients];
  
  // Give each drawer a random color
  clientDrawColors = new color[maxclients];
  for (int i = 0; i < clientDrawColors.length; i ++) {
    clientDrawColors[i] = color (
      random(0, 255),
      random(0, 255),
      random(0, 255)
    );
  }
 
  clearPad();
  noStroke();
  
  cp5.addButton("clearPad")
    .setPosition(10, 10)
    .setSize(200, 20)
    .setLabel("Clear Drawing Pad")
    .updateSize()
    ;
  
  server = new Server(this, port);
}

void draw () {
  
  Client client = server.available();
  
  if (client != null) {
    String message = client.readStringUntil(10);
    if (message != null) {
      
      message = trim(message);
      
      String [] tokens = split(message, " ");
      
      String command = tokens[0];
            
      if (command.equals("REQID")) {
        // Find the next available slot
        boolean foundSpot = false;
        for (int i = 0; i < clients.length; i++) {
          if (clients[i] == null) {
            clients[i] = client;
            client.write("" + i);
            client.write(10);
            foundSpot = true;
            
            println(i);
            
            break;
          }
        }
      }
      else if (command.equals("UPDATE")) {
        
        int id = int(tokens[1]);
        int x = int(tokens[2]);
        int y = int(tokens[3]);
        
        if (id >= 0 && id < clients.length) {
          if (client.ip().equals(clients[id].ip())) {
            // Scale x and y to window size
            x = round((x / 1024.0) * width);
            y = round((y / 1024.0) * height);
            
            println(id + " " + x + " " + y);
          }
        }
        
        
        fill(clientDrawColors[id]);
        
        ellipse(
          (width / 2) + x,
          (height / 2) + y,
          20,
          20
        );
      }
      if (command.equals("DIE")) {
        int id = int(tokens[1]);
        clients[id] = null;
      }
    }
  }
}

void clearPad () {
  background(255);
  
  fill(0);
  text("IP: " + getIP(), 220, 25);
}

String getIP () {
  String ip = "";
  
  try {
    ip = java.net.InetAddress.getLocalHost().getHostAddress();
  }
  catch (Exception e) {
    
  }
  
  return ip;
}

void updateClientList () {
  int numClients = 0;
  for (int i = 0; i < clients.length; i++ ) {
    if (clients[i] != null) {
      numClients++;
    }
  }
  connectedClients = numClients;
}

void keyPressed () {
  if (keyCode == 122) {
    if (fs.isFullScreen() == true) {
      fs.leave();
    }
    else {
      fs.enter();
      
    }
  }
}

