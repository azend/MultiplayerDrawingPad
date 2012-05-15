package processing.android.test.multiplayerdrawingpad_client;

import processing.core.*; 

import apwidgets.*; 
import processing.net.*; 

import processing.net.*; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class MultiplayerDrawingPad_Client extends PApplet {




APWidgetContainer widgetContainer; 
APEditText ipAddressField;
APButton changeAddress;

String ip;
int port;

Client client;

int id;

int joyX;
int joyY;
boolean buttonIsPressed;

boolean changed;

int halfwidth;
int halfheight;

public void setup () {
	// size( 400, 400 );

        ip = "192.168.1.100";
        port = 50249;

        widgetContainer = new APWidgetContainer(this); //create new container for widgets
        ipAddressField = new APEditText(5, 5, 200, 50); //create a textfield from x- and y-pos., width and height
        changeAddress = new APButton( 205, 5, 80, 50, "Connect");
        widgetContainer.addWidget(ipAddressField); //place textField in container
        widgetContainer.addWidget(changeAddress);
	smooth();

	halfwidth = width / 2;
	halfheight = height / 2;

        ipAddressField.setText(ip);

}

public void draw () {
	if (client != null && id > -1) {
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
                        int scaledX = round( ( joyX / ( width * 1.0f ) ) * 1024.0f );
                        int scaledY = round( ( joyY / ( height * 1.0f ) ) * 1024.0f );
			client.write("UPDATE " + id + " " + scaledX + " " + scaledY);
			client.write(10); // Write newline
			changed = false;
		}
                
                fill(0);
                text( id, 10, 20 );
        }
        else if (client != null && id <= -1) {
          background(255, 0, 0);
        }

	else {
	  background(0);
	}

}

public void mouseDragged () {
	joyX = mouseX - halfwidth;
	joyY = mouseY - halfheight;

	changed = true;
}

public void mousePressed () {
	buttonIsPressed = true;
	changed = true;

}

public void mouseReleased () {
	buttonIsPressed = false;
	changed = true;
}

public void initConnection () {
  client = new Client(this, ip, port);

  id = -1;
  
  if (client != null) {
    // Ask for a spot
    client.write("REQID");
    client.write(10);
    
    delay (200);
     
    // Wait until we recieve our response
    while (client.available() == 0) {delay(100);}
    
    if (client.available() > 0 ) {
      String message = client.readStringUntil(10);
      
      message = trim(message);
          
      id = PApplet.parseInt(message);
      
      println( "ID acquired.. " + id);
    }
  }

}

public void stopConnection () {
  client.write("DIE " + id);
  client.write(10);
  id = -1;
  client = null;
}

public void stop () {
  stopConnection();
}

public void onClickWidget(APWidget widget){
  
  if(widget == changeAddress){ //if it was button1 that was clicked
    if (client == null) {
      String [] address = split(trim(ipAddressField.getText()), ":");
      
      if ( address[0] != "" ) {
        ip = address[0];
        
        if ( address.length > 1 ) {
          port = PApplet.parseInt(address[1]);
        }
      }
      
      initConnection();
      
      changeAddress.setText("Disconnect");
    }
    
    else {
      stopConnection();
      
      changeAddress.setText("Connect");
    }
  }
  
}

}
