import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.Scanner;

import message.*;

public class client {
    static public void main(String[] args) throws IOException {
        String adresa = config.SERVERADDRESS; int port = config.SERVERPORT;

        Socket cs = null;
        System.out.println("Incerc sa fac socketul");
        try { cs = new Socket(adresa,port); }
        catch(Exception e) {
            System.out.println("Conexiune esuata");
            System.exit(1);
        }

        System.out.println(cs.getInputStream());
        System.out.println(cs.getOutputStream());

        ObjectInputStream dis; ObjectOutputStream dos;
        dos = new ObjectOutputStream(cs.getOutputStream());
        dis = new ObjectInputStream(cs.getInputStream());

        String linie;

        Scanner sc = new Scanner(System.in);
        BaseMessage lastResponse = null;
        for( ; ; ) {
            if (lastResponse != null) {
                lastResponse.serialise(dos);
            } else {
                // for debug purpose only
                System.out.print("Requesting message to send: ");
                int value = sc.nextInt();

                if (value == -1) {
                    menu.Request request
                }

                Foo message = new Foo(value);
                message.serialise(dos);
            }

            try {
                lastResponse = MessageAgregator.onNetworkMessage(dis);
            } catch (Exception e) {
                break;
            }
        }

        cs.close(); dis.close(); dos.close();
    }
}
