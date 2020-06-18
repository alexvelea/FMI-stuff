import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Scanner;

import java.sql.ResultSet;
import java.sql.Statement;

import database.*;
import message.*;

public class server {
    public static void main (String[] args) throws IOException, java.sql.SQLException {
        DatabaseConnection conn = DatabaseConnection.getSingleton();

        System.out.println("Database connection established!");

//        Menu menu = new Menu();
//        ArrayList<FullRecipe> all = menu.getRecipes();
//
//        for (FullRecipe f : all) {
//            System.out.println(f);
//        }

        startServer(config.SERVERPORT);
    }

    static void startServer(int socketPort) throws IOException {
        ServerSocket ss = null; Socket cs = null;
        ss = new ServerSocket(socketPort);

        System.out.println("Serverul a pornit !");

        cs = ss.accept();

        System.out.println(cs.getInputStream());
        System.out.println(cs.getOutputStream());

        ObjectInputStream dis; ObjectOutputStream dos;
        try {
            dis = new ObjectInputStream(cs.getInputStream());
            dos = new ObjectOutputStream(cs.getOutputStream());
        } catch (Exception e) {
            System.out.println(e);
            return;
        }

        String linie;
        Scanner sc = new Scanner(System.in);

        for( ; ; ) {
            try {
                BaseMessage response = MessageAgregator.onNetworkMessage(dis);
                if (response != null) {
                    response.serialise(dos);
                } else {
                    // for debug purpose only
                    System.out.print("Requesting message to send: ");
                    int value = sc.nextInt();
                    Foo message = new Foo(value);
                    message.serialise(dos);
                }

                dos.flush();
            } catch (Exception e) {
                System.out.println(":(" + e);
                break;
            }
        }

        cs.close(); dis.close(); dos.close();
    }
}
