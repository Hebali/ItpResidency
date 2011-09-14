/**
 * The "Most Pixels Ever" Wallserver.
 * This server can accept two values from the command line:
 * -port<port number> Defines the port.  Defaults to 9002
 * -ini<Init file path>  File path to mpeServer.ini.  Defaults to directory of server.
 * @author Shiffman and Kairalla
 *
 */

package server;

import java.io.IOException;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;

import java.io.IOException;
import java.net.Socket;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;

import processing.core.PApplet;

import controlP5.*;

public class MPEServerGui extends PApplet {
	ControlP5 	controlP5;
	Toggle 		debugMode;
	Button 		startButton;
	Textfield 	screensText,frateText,portText,listenText;
	
	int 		screensVal,frateVal,portVal,listenVal;  
    boolean 	debugVal;
	
	public static void main(String[] args) {
    	PApplet.main(new String[] {"server.MPEServerGui"});
    }
    
    public void setup() {
    	size(300,300);
    	
    	controlP5 = new ControlP5(this);

	    // Setup buttons
	    screensText = controlP5.addTextfield("Screens",95,20,50,20);
	    screensText.setText("3");
	    screensText.setFocus(true);
	    frateText = controlP5.addTextfield("Framerate",155,20,50,20);
	    frateText.setText("30");
	    frateText.setFocus(false);
	    portText = controlP5.addTextfield("Port",95,60,50,20);
	    portText.setText("9002");
	    portText.setFocus(false);
	    listenText = controlP5.addTextfield("Listen Port",155,60,50,20);
	    listenText.setText("9003");
	    listenText.setFocus(false);
	    // Setup toggle
	    debugMode = controlP5.addToggle("Debug Mode",false,140,100,20,20);
	    // Setup button
	    startButton = controlP5.addButton("start",0,100,150,100,20);
    }
    public void draw() {
    	background(0);
    }
    
    public void start(int theValue) {
    	  screensVal = Integer.parseInt(screensText.getText());
    	  frateVal = Integer.parseInt(frateText.getText());
    	  portVal  = Integer.parseInt(portText.getText());
    	  listenVal = Integer.parseInt(listenText.getText());  
    	  debugVal = debugMode.getState();
    	  // Run Server
          MPEServer ws = new MPEServer(screensVal,frateVal,portVal,listenVal);
          ws.run();
    }
    
    public class MPEServer {
        private ArrayList<Connection> connections = new ArrayList<Connection>();
        private int port;
        private boolean running = false;
        public boolean[] connected;  // When the clients connect, they switch their slot to true
        public boolean[] ready;      // When the clients are ready for next frame, they switch their slot to true
        public boolean allConnected = false;  // When true, we are off and running
        int frameCount = 0;
        private long before;
        
        // Server will add a message to the frameEvent
        public boolean newMessage = false;
        public String message = "";
        
        // Server can send a byte array!
        public boolean newBytes = false;
        public byte[] bytes = null;
        
        // Server can send an int array!
        public boolean newInts = false;
        public int[] ints = null;
        
        public boolean dataload = false;

        // Back door connection stuff
        ListenerConnection backDoorConnection = null;
        private boolean listener = false;
        private int listenPort;
        private boolean backDoorConnected = false;
        BackDoor backdoor;
        
        public MPEServer(int _screens, int _framerate, int _port, int _listenPort) {
            port = _port;
            listenPort = _listenPort;
            out("framerate = " + frateVal + ",  screens = " + screensVal + ", debug = " + debugVal);
            
            connected = new boolean[screensVal];  // default to all false
            ready = new boolean[screensVal];      // default to all false
        }
        
        public void run() {
            running = true;
            if (listener) startListener();
            before = System.currentTimeMillis(); // Getting the current time
            ServerSocket frontDoor;
            try {
                frontDoor = new ServerSocket(port);

                System.out.println("Starting server: " + InetAddress.getLocalHost() + "  " + frontDoor.getLocalPort());

                // Wait for connections (could thread this)
                while (running) {
                    Socket socket = frontDoor.accept();  // BLOCKING!                       
                    System.out.println(socket.getRemoteSocketAddress() + " connected.");
                    // Make  and start connection object
                    Connection conn = new Connection(socket,this);
                    conn.start();
                    // Add to list of connections
                    connections.add(conn); 
                }
            } catch (IOException e) {
                System.out.println("Zoinks!" + e);
            }
        }
        
        // Synchronize?!!!
        public synchronized void triggerFrame() {
            if (frameCount % 10 == 0) {
                //System.out.println("Framecount: " + frameCount);
            }
            
            // We can't go on if the server is still loading data from a client
            /*while (dataload) {
                System.out.println("Data loading!");
                try {
                    Thread.sleep(5);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }*/

            int desired = (int) ((1.0f / (float)frateVal) * 1000.0f);
            long now = System.currentTimeMillis();
            int diff = (int) (now - before);
            if (diff < desired) {
                // Where do we max out a framerate?  Here?
                try {
                    long sleepTime = desired-diff;
                    if (sleepTime >= 0){
                        Thread.sleep(sleepTime);
                    }
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            } else {
                try {
                    long sleepTime = 2;
                    Thread.sleep(sleepTime);
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            // Reset everything to false
            for (int i = 0; i < ready.length; i++) {
                ready[i] = false;
            }        

            frameCount++;
            
            String send = "G,"+(frameCount-1);
            
            // Adding a data message to the frameEvent
            //substring removes the ":" at the end.
            if (newMessage) send += ":" + message.substring(0, message.length()-1);
            newMessage = false;
            message = "";
            
            if (newBytes) {
              send = "B" + send;
              sendAll(send);
              sendAllBytes();
              newBytes = false;
            } else if (newInts) {
              send = "I" + send;
              sendAll(send);
              sendAllInts();
              newInts = false;
            } else {
              sendAll(send);
            }
            before = System.currentTimeMillis();
        }

        private void printMsg(String string) {
            System.out.println("MPEServer: "+string);

        }

        public synchronized void sendAll(String msg){
            //System.out.println("Sending " + msg + " to clients: " + connections.size());
            for (int i = 0; i < connections.size(); i++){
                Connection conn = connections.get(i);
                conn.send(msg);
            }
        }
        
        public synchronized void sendAllBytes(){
            //System.out.println("Sending " + msg + " to clients: " + connections.size());
            for (int i = 0; i < connections.size(); i++){
                Connection conn = connections.get(i);
                conn.sendBytes(bytes);
            }
        }
        
        public synchronized void sendAllInts(){
            //System.out.println("Sending " + msg + " to clients: " + connections.size());
            for (int i = 0; i < connections.size(); i++){
                Connection conn = connections.get(i);
                conn.sendInts(ints);
            }
        }

        public void killConnection(Connection conn){
            connections.remove(conn);
        }

        boolean allDisconected(){
            if (connections.size() < 1){
                return true;
            } else return false;
        }
        void resetFrameCount(){
            frameCount = 0;
            newMessage = false;
            message = "";
            printMsg("resetting frame count.");
        }
        public void killServer() {
            running = false;
        }
        
        private void out(String s){
            System.out.println("WallServer: "+ s);
        }

        public void drop(int i) {
            connected[i] = false;
            ready[i] = false;
        }

        // synchronize??
        public synchronized void setReady(int clientID) { 
            ready[clientID] = true;
            if (isReady()) triggerFrame();
        }

        // synchronize?
        public synchronized boolean isReady() {
            boolean allReady = true;
            for (int i = 0; i < ready.length; i++){  //if any are false then wait
                if (ready[i] == false) allReady = false;
            }
            return allReady;
        }

    //********************** BACKDOOR LISTENER METHODS **********************************
        private void startListener(){
           backdoor = new BackDoor(this);
           Thread t= new Thread(backdoor);
           t.start();
        }
        public void killListenerConnection(){
        	backDoorConnected = false;
        }
        
        class BackDoor implements Runnable{
        	MPEServer parent;
        	BackDoor(MPEServer _parent){
        		parent = _parent;
        	}
        	
    		public void run() {
    			 ServerSocket backDoor;
    			 ListenerConnection backDoorConnection;
    		    	try {
    		            backDoor= new ServerSocket(listenPort);
    		            System.out.println("Starting backdoor Listener: " + InetAddress.getLocalHost() + "  " + backDoor.getLocalPort());
    		            while (running) {
    		                if (!backDoorConnected){
    		                	System.out.println("Waiting for backdoor connection");
    		                Socket socket = backDoor.accept();  // BLOCKING!
    		                System.out.println("backdoor port "+socket.getRemoteSocketAddress() + " connected.");
    		                // Make  and start connection object
    		                backDoorConnection = new ListenerConnection(socket,parent);
    		                backDoorConnection.start();
    		                backDoorConnected= true;
    		                } else {
    							Thread.sleep(500);
    		                }
    		            }
    		        } catch (IOException e) {
    		            System.out.println("Zoinks, Backdoor Style!" + e);
    		        } catch (InterruptedException e) {
    					// TODO Auto-generated catch block
    					e.printStackTrace();
    				}
    			
    		}
        	
        }
    }

    public class ListenerConnection extends Connection {
    	String inputString = "";
        ListenerConnection(Socket socket_, MPEServer p) {
        	super(socket_, p);
            uniqueName = "Listener Conn" + socket.getRemoteSocketAddress();
        }

        public void run() {
      	  int readIn = 0;
            while (running) {
                try {
                	  String msg = null;
    				readIn = in.read();
    				if (readIn == -1){
                        killMe();
                        break;
    				} else {
    					msg = read((char)readIn);
    					if (msg != null){
    						if (debugVal) print ("received from backdoor: " + msg);
    						//only attach to message if everyone's connected.
    						if (parent.allConnected){
    			            parent.newMessage = true;
    			            parent.message += msg+":";
    						}
    					}
    				}
                    
                } catch (IOException e) {
                    System.out.println("Listener connection just died." + e);
                    killMe();
                    break;
                }            
            }

        }

        private void print(String string) {
            System.out.println("Connection: "+string);

        }
        
        private String read(char in){
      	  String back = null;
      		if (in =='\n'){
      			back = new String(inputString);
      			inputString = "";
      		} else {
      			inputString = inputString+in;
      		}
      		return back;
      	}
        /**
         * prints string as a stream of characters to client
         * @param out
         */
        public void send(String out) {
      	  out+="\n";
      	try {
      		os.write(out.getBytes());
      		os.flush();
      	} catch (IOException e) {
      		// TODO Auto-generated catch block
      		e.printStackTrace();
      	}
      }
        public void killMe(){
            System.out.println("Removing Listener Connection " + clientID);
            running = false;
            parent.killListenerConnection();
        }

    }
    
    public class Connection extends Thread {
        Socket socket;

        InputStream in;
        OutputStream os;
        //DataInputStream dis;
        BufferedReader brin;
        DataOutputStream dos;

        //CyclicBarrier barrier;

        int clientID = -1;
        String uniqueName;

        String msg = "";

        boolean running = true;
        MPEServer parent;

        Connection(Socket socket_, MPEServer p) {
            //barrier = new CyclicBarrier(2);
            socket = socket_;
            parent = p;
            uniqueName = "Conn" + socket.getRemoteSocketAddress();
            // Trade the standard byte input stream for a fancier one that allows for more than just bytes (dano)
            try {
                in = socket.getInputStream();
                //dis = new DataInputStream(in);
                brin = new BufferedReader(new InputStreamReader(in));
                os = socket.getOutputStream();
                dos = new DataOutputStream(os);
            } catch (IOException e) {
                System.out.println("couldn't get streams" + e);
            }
        }

        void read(String msg) {
            //if (mpePrefs.DEBUG) System.out.println("Raw receive: " + this + ": " + msg);


            // A little bit of a hack, it seems there are blank messages sometimes??
            char startsWith =  ' ';
            if (msg.length() > 0) startsWith = msg.charAt(0);

            switch(startsWith){
            // For Starting Up
            case 'S':
                if (debugVal) System.out.println(msg);
                //do this with regex eventually, but for now..
                //(DS: also, probably just use delimiter and split?)
                //this is in serious need of error checking.
                int start = 1;
                clientID = Integer.parseInt(msg.substring(start));
                System.out.println("Connecting Client " + clientID);
                parent.connected[clientID] = true;
                boolean all = true;
                for (int i = 0; i < parent.connected.length; i++){  //if any are false then wait
                    if (parent.connected[i] == false) {
                    	all = false;
                    	break;
                    }
                }
                parent.allConnected = all;
                if (parent.allConnected) parent.triggerFrame();
                break;
                //is it receiving a "done"?
            case 'D':   
                if (parent.allConnected) {
                    // Networking protocol could be optimized to deal with bytes instead of chars in a String?
                    String[] info = msg.split(",");
                    clientID = Integer.parseInt(info[1]);
                    int fc = Integer.parseInt(info[2]);
                    if (debugVal) System.out.println("Receive: " + clientID + ": " + fc + "  match: " + parent.frameCount);
                    if (fc == parent.frameCount) {
                        parent.setReady(clientID);
                        //if (parent.isReady()) parent.triggerFrame();
                    }
                }
                break;
                //is it receiving a "daTa"?
            case 'T':   
                if (debugVal) print ("adding message to next frameEvent: " + msg);
                parent.newMessage = true;
                parent.message += msg.substring(1,msg.length())+":";
                //parent.sendAll(msg);
                break;
            /*case 'B':
                // Reading in byte arrays
                parent.dataload = true;
                try {
                    int len = dis.readInt();
                    if (mpePrefs.DEBUG) System.out.println("Reading byte array, size: :  " + len);
                    byte[] data = new byte[len];
                    dis.read(data, 0, len);
                    parent.newBytes = true;
                    parent.bytes = data;
                } catch (IOException e) {
                    e.printStackTrace();
                }
                parent.dataload = false;
                break;
            case 'I':
                parent.dataload = true;
                // Reading in int arrays
                try {
                    int len = dis.readInt();
                    if (mpePrefs.DEBUG) System.out.println("Reading int array, size: :  " + len);
                    int[] data = new int[len];
                    for (int i = 0; i < data.length; i++) {
                        data[i] = dis.readInt();
                    }
                    //if (mpePrefs.DEBUG) System.out.println("Anything left? " + dis.available());
                    parent.newInts = true;
                    parent.ints = data;
                } catch (IOException e) {
                    e.printStackTrace();
                }
                parent.dataload = false;
                break;*/       
            }
        }

        public void run() {
            while (running) {
                //String msg = null;
                try {
                    String input = brin.readLine();
                    if (input != null) {
                        read(input);
                    } else {
                        killMe();
                        // running = false; ?? or break?
                        break;
                    }

                    /*try {
                        Thread.sleep(5);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }*/
                } catch (IOException e) {
                    System.out.println("Someone left?  " + e);
                    killMe();
                    break;
                }            
            }

        }

        private void print(String string) {
            System.out.println("Connection: "+string);

        }

        public void killMe(){
            System.out.println("Removing Connection " + clientID);
            parent.killConnection(this);
            parent.drop(clientID);
            running = false;
            if (parent.allDisconected()) parent.resetFrameCount();
        }

        // Trying out no synchronize
        public void send(String msg) {
            if (debugVal) System.out.println("Sending: " + this + ": " + msg);
            try {
            	msg+="\n";
                dos.write(msg.getBytes());
                dos.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // Trying out no synchronize
        public void sendBytes(byte[] b) {
            if (debugVal) System.out.println("Sending " + b.length + " bytes");
            try {
                dos.writeInt(b.length);
                dos.write(b,0,b.length);
                dos.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // Trying out no synchronize
        public void sendInts(int[] ints) {
            if (debugVal) System.out.println("Sending " + ints.length + " ints");
            try {
                dos.writeInt(ints.length);
                for (int i = 0; i < ints.length; i++) {
                    dos.writeInt(ints[i]);
                }
                dos.flush();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }


    }
}
