package database;

import java.sql.*;

public class Ingredient extends BaseModel {
    public int id = 0;
    public String name;
    public float price;
    public String quantityUnit;

    public float quantity = 0;

    public Ingredient() {
    }

    public Ingredient(ResultSet rs) throws java.sql.SQLException {
        this.fromSQL(rs);
    }

    @Override
    public void fromSQL(ResultSet rs) throws java.sql.SQLException {
        this.id = rs.getInt(1);
        this.name = rs.getString(2);
        this.price = rs.getFloat(3);
        this.quantityUnit = rs.getString(4);
    }

    @Override
    public String toString() {
        return "id:" + this.id + "\t" +
                "name:" + this.name + "\t" +
                "price:" + this.price + "\t" +
                "quantityUnit:" + this.quantityUnit;
    }

    @Override
    public void save() throws java.sql.SQLException {
        PreparedStatement statement;

        if (this.id == 0) {
            statement = DatabaseConnection.getSingleton().connection.prepareStatement("" +
                    "INSERT INTO ingredient (name, price, quantity_unit) VALUE (?, ?, ?)", Statement.RETURN_GENERATED_KEYS);
        } else {
            statement = DatabaseConnection.getSingleton().connection.prepareStatement("" +
                    "UPDATE ingredient SET name = ?, price = ?, quantity_unit = ? WHERE id = ?", Statement.RETURN_GENERATED_KEYS);
            statement.setInt(4, this.id);
        }

        statement.setString(1, this.name);
        statement.setFloat(2, this.price);
        statement.setString(3, this.quantityUnit);

        int affectedRows = statement.executeUpdate();

        if (affectedRows == 0) {
            throw new SQLException("Creating user failed, no rows affected.");
        }

        if (this.id == 0) {
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    this.id = generatedKeys.getInt(1);
                } else {
                    throw new SQLException("Creating an ingredient failed, no ID obtained.");
                }
            }
        }
    }
}
