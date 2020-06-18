package message;

import database.DatabaseConnection;
import database.Ingredient;
import database.Recipe;
import database.RecipeIngredient;

import java.sql.ResultSet;
import java.util.ArrayList;

public class FullRecipe {
    final int recipeId;

    Recipe recipe = null;
    ArrayList<Ingredient> ingredients = null;

    public FullRecipe(int recipeId) {
        this.recipeId = recipeId;
        this.ensure();
    }

    public FullRecipe(Recipe r) {
        this.recipe = r;
        this.recipeId = this.recipe.id;
        this.ensure();
    }

    @Override
    public String toString() {
        float price = this.recipe.addedCost;
        for (Ingredient i : this.ingredients) {
            price += i.quantity * i.price;
        }

        StringBuilder sb = new StringBuilder();

        sb.append("Name:" + this.recipe.shortName + "\n");
        sb.append("Price:" + price + "\n");
        sb.append("Description:" + this.recipe.description + "\n");
        sb.append("~~~Ingredients~~~\n");
        for (Ingredient i : this.ingredients) {
            sb.append("     " + i.name + "\t" + i.quantity + " " + i.quantityUnit + "\n");
        }

        return sb.toString();
    }

    public void ensure() {
        this.ensureRecipe();
        this.ensureIngredients();
    }

    public void ensureRecipe() {
        if (this.recipe != null) {
            return;
        }

        try {
            ResultSet rs = DatabaseConnection.getSingleton().connection.createStatement().executeQuery(
                    "SELECT * FROM recipe WHERE id = " + recipeId);
            this.recipe = new Recipe(rs);
        } catch (Exception e) {
            System.out.println("It seems we don't have that recipe, sire! id="+ this.recipeId + " - " + e);
        }
    }

    public void ensureIngredients() {
        if (this.ingredients != null) {
            return;
        }

        // Get all recipe-ingredients

        ArrayList<RecipeIngredient> ri = new ArrayList<>();

        try {
            ResultSet rs = DatabaseConnection.getSingleton().connection.createStatement().executeQuery(
                    "SELECT * FROM recipe_ingredient WHERE recipe_id = " + recipeId);

            while(rs.next()) {
                ri.add(new RecipeIngredient(rs));
            }
        } catch (Exception e) {
            System.out.println("It seems we don't have that recipe_ingredient, sire! id="+ this.recipeId + " - " + e);
            return;
        }

        this.ingredients = new ArrayList<>();
        for (RecipeIngredient recipeIngredient : ri) {
            try {

                    ResultSet rs = DatabaseConnection.getSingleton().connection.createStatement().executeQuery(
                            "SELECT * FROM ingredient WHERE id = " + recipeIngredient.ingredientId);
                    if (rs.next()) {
                        Ingredient i = new Ingredient(rs);
                        i.quantity = recipeIngredient.quantity;
                        this.ingredients.add(i);
                    }
            } catch (Exception e) {
                System.out.println("It seems we don't have that ingredient, sire! id="+ recipeIngredient.ingredientId + " - " + e);
            }
        }
    }
}
