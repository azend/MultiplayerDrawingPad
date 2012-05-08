
import processing.net.*;

Client client;

int id;

int joyX;
int joyY;
boolean buttonIsPressed;

boolean changed;

int halfwidth;
int halfheight;

void setup () {
	// size( 400, 400 );
	smooth();

	halfwidth = width / 2;
	halfheight = height / 2;

	initConnection();
}

void draw () {
	if (client != null) {
		background(255);
		noFill();

		
		ellipse(
			halfwidth + joyX,
			halfheight + joyY,
			30,
			30
		);
		

		line(
			halfwidth,
			halfheight,
			halfwidth + joyX,
			halfheight + joyY
		);

		if (changed) {
                        int scaledX = round( ( joyX / ( width * 1.0 ) ) * 1024.0 );
                        int scaledY = round( ( joyY / ( height * 1.0 ) ) * 1024.0 );
			client.write("UPDATE " + id + " " + joyX + " " + joyY);
			client.write(10); // Write newline
			changed = false;
		}
                
                fill(0);
                text( id, 10, 20 );
        }

	else {
		background(255, 0, 0);
	}

}

void mouseDragged () {
	joyX = mouseX - halfwidth;
	joyY = mouseY - halfheight;

	changed = true;
}

void mousePressed () {
	buttonIsPressed = true;
	changed = true;

}

void mouseReleased () {
	buttonIsPressed = false;
	changed = true;
}

void initConnection () {
  client = new Client(this, "192.168.43.66", 8080);
  
  // Ask for a spot
  client.write("REQID");
  client.write(10);
  
  delay (200);
  
  // Wait until we recieve our response
  while (client.available() == 0) {background(255, 0, 0);}
  
  if (client.available() > 0 ) {
    String message = client.readStringUntil(10);
    
    message = trim(message);
        
    id = int(message);
    
    println( "ID acquired.. " + id);
  }
  
}

void stopConnection () {
  client.write("DIE " + id);
  client.write(10);
  client = null;
}

void stop () {
  stopConnection();
}
