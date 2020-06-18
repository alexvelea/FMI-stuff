package database;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class RecipeIngredient extends BaseModel {
    public int recipeId;
    public int ingredientId;
    public float quantity;

    Recipe recipe = null;
    Ingredient ingredient = null;
    private Boolean justCreated = false;

    public RecipeIngredient() {
        this.justCreated = true;
    }

    public RecipeIngredient(ResultSet rs) throws java.sql.SQLException {
        this.fromSQL(rs);
        this.justCreated = false;
    }

    @Override
    public void fromSQL(ResultSet rs) throws java.sql.SQLException {
        this.recipeId = rs.getInt(1);
        this.ingredientId = rs.getInt(2);
        this.quantity = rs.getFloat(3);
    }

    @Override
    public void save() throws java.sql.SQLException {
        PreparedStatement statement;

        if (this.justCreated) {
            statement = DatabaseConnection.getSingleton().connection.prepareStatement("" +
                    "INSERT INTO recipe_ingredient (recipe_id, ingredient_id, quantity) VALUE (?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
            statement.setInt(1, this.recipeId);
            statement.setInt(2, this.ingredientId);
            statement.setFloat(3, this.quantity);
        } else {
            statement = DatabaseConnection.getSingleton().connection.prepareStatement("" +
                    "UPDATE recipe_ingredient SET quantity = ? WHERE recipe_id = ? AND ingredient_id = ?", Statement.RETURN_GENERATED_KEYS);
            statement.setFloat(1, this.quantity);
            statement.setInt(2, this.recipeId);
            statement.setInt(3, this.ingredientId);
        }

        int affectedRows = statement.executeUpdate();

        if (affectedRows == 0) {
            throw new SQLException("Creating user failed, no rows affected.");
        }
    }
}
