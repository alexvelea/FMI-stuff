package message.menu;

import database.DatabaseConnection;
import database.Recipe;

import java.io.ObjectOutputStream;
import java.sql.ResultSet;
import java.util.ArrayList;

import message.FullRecipe;
import message.BaseMessage;

class Response extends BaseMessage {
    private ArrayList<FullRecipe> recipes = null;

    public ArrayList<FullRecipe> getRecipes() {
        if (recipes != null) {
            return recipes;
        }

        recipes = new ArrayList<>();

        try {
            ResultSet rs = DatabaseConnection.getSingleton().connection.createStatement().executeQuery(
                    "SELECT * FROM recipe");

            while(rs.next()) {
                Recipe r = new Recipe(rs);
                recipes.add(new FullRecipe(r));
            }
        } catch (Exception e) {
            System.out.println("It seems we have a problem with our menu, sire!" + e);
        }

        return recipes;
    }

    @Override
    public BaseMessage onNetworkMessage() {
        ArrayList<FullRecipe> all = getRecipes();

        for (FullRecipe f : all) {
            System.out.println(f);
        }

        return null;
    }

    @Override
    public void serialise(ObjectOutputStream out) throws java.io.IOException {
        out.writeObject(this);
    }

    public void ensureData() {
        this.getRecipes();
    }

//    public Menu getMenu() {
//        return this.menu;
//    }
//
//    public void setMenu(Menu menu) {
//        this.menu = menu;
//    }

//    @Override
//    public String toString() {
//        return "Foo [coolValue=" + coolValue + "]";
//    }
}