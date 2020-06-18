package database;

import java.sql.ResultSet;

public class RecipeComplexity extends BaseModel {
    public int id;
    public String str;

    RecipeComplexity() {
    }

    RecipeComplexity(ResultSet rs) throws java.sql.SQLException {
        this.fromSQL(rs);
    }

    @Override
    public void fromSQL(ResultSet rs) throws java.sql.SQLException {
        this.id = rs.getInt(1);
        this.str = rs.getString(2);
    }

    @Override
    public void save() throws java.sql.SQLException {
    }
}
