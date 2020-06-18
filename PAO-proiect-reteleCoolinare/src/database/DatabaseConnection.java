package database;

import java.io.FileNotFoundException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Scanner;
import java.io.File;

public class DatabaseConnection {
    private String username;
    private String password;
    static private Boolean isInitialised = false;
    static private DatabaseConnection object = null;

    public Connection connection;

    private DatabaseConnection() throws java.sql.SQLException {
        this.Initialise();
    }

    private void GetCredentials() throws FileNotFoundException {
        Scanner s = new Scanner(new File(System.getProperty("user.home") + "/.reteteCoolinare.credentials"));
        this.username = s.next();
        this.password = s.next();
        s.close();
    }

    private void Initialise() throws java.sql.SQLException {
        isInitialised = true;

        try {
            this.GetCredentials();
            System.out.println("username:" + this.username + "\n" + "password:" + this.password);
        } catch (FileNotFoundException e) {
            System.out.println("Can't locate credentials file! Should be '" + System.getProperty("user.home") + "/.reteteCoolinare.credentials'");
            return;
        }

        connection = DriverManager.getConnection("jdbc:mysql://localhost/reteteCoolinare", this.username, this.password);
        System.out.println(connection);
    }

    static public DatabaseConnection getSingleton() {
        if (DatabaseConnection.isInitialised) {
            return object;
        }

        try {
            object = new DatabaseConnection();
        } catch (java.sql.SQLException e) {
            System.out.println("An unexpected dinosaur happened while seting up the DB " + e);
            System.exit(0);
        }

        return object;
    }

}
