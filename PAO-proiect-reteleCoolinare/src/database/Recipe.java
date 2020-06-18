package database;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Recipe extends BaseModel {
    public int id;
    public int preparationTimeSec;
    public int recipeComplexityId;
    public String description;
    public String shortName;
    public int addedCost;

    RecipeComplexity recipeComplexity;

    public Recipe() {
    }

    public Recipe(ResultSet rs) throws java.sql.SQLException {
        this.fromSQL(rs);
    }

    public void fromSQL(ResultSet rs) throws java.sql.SQLException {
        this.id = rs.getInt(1);
        this.preparationTimeSec = rs.getInt(2);
        this.recipeComplexityId = rs.getInt(3);
        this.description = rs.getString(4);
        this.shortName = rs.getString(5);
        this.addedCost = rs.getInt(6);
    }

    @Override
    public String toString() {
        return "id:" + this.id + "\t" +
                "preparationTimeSec:" + this.preparationTimeSec + "\t" +
                "recipeComplexityId:" + this.recipeComplexityId + "\t" +
                "description:" + this.description + "\t" +
                "shortName:" + this.shortName + "\t" +
                "addedCost:" + this.addedCost;
    }

    @Override
    public void save() throws java.sql.SQLException {
        PreparedStatement statement;

        if (this.id == 0) {
            statement = DatabaseConnection.getSingleton().connection.prepareStatement("" +
                    "INSERT INTO recipe (preparation_time_sec, recipe_complexity_id, description, short_name, added_cost) VALUE (?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
        } else {
            statement = DatabaseConnection.getSingleton().connection.prepareStatement("" +
                    "UPDATE recipe SET preparation_time_sec = ?, recipe_complexity_id = ?, description = ?, short_name= ?, added_cost = ? WHERE id = ?", Statement.RETURN_GENERATED_KEYS);
            statement.setInt(6, this.id);
        }

        statement.setInt(1, this.preparationTimeSec);
        statement.setInt(2, this.recipeComplexityId);
        statement.setString(3, this.description);
        statement.setString(4, this.shortName);
        statement.setInt(5, this.addedCost);

        int affectedRows = statement.executeUpdate();

        if (affectedRows == 0) {
            throw new SQLException("Creating user failed, no rows affected.");
        }

        if (this.id == 0) {
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    this.id = generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating a recipe failed, no ID obtained.");
                }
            }
        }
    }
}
