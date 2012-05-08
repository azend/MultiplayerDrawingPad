import processing.net.*;

final int maxclients = 30;
final int port = 8080;

Server server;

Client clients [];
color clientDrawColors [];

void setup () {
  size(400, 400);
  
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
 
  background(255);
  noStroke();
  
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
        
        // Scale x and y to window size
        x = round((x / 1024.0) * width);
        y = round((y / 1024.0) * height);
        
        println(id + " " + x + " " + y);
        
        
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


