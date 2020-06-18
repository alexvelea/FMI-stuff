package database;

import java.sql.ResultSet;

public abstract class BaseModel {
    abstract public void fromSQL(ResultSet rs) throws java.sql.SQLException;
    abstract public void save() throws java.sql.SQLException;
}
