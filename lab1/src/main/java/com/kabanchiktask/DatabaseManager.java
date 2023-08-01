package com.kabanchiktask;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DatabaseManager {
    private DatabaseConnector databaseConnector;
    private String directoryPath;

    public DatabaseManager(DatabaseConnector databaseConnector, String directoryPath) {
        this.databaseConnector = databaseConnector;
        this.directoryPath = directoryPath;
    }

    public String getDirectoryPath() {
        return directoryPath;
    }

    public String readSqlScript(String filename) {
        StringBuilder scriptBuilder = new StringBuilder();

        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(directoryPath + filename);
             BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {

            String line;
            while ((line = reader.readLine()) != null) {
                scriptBuilder.append(line).append("\n");
            }
        } catch (IOException e) {
            throw new RuntimeException("Error reading SQL script: " + e.getMessage(), e);
        }

        return scriptBuilder.toString();
    }


    public void executeSQL(String sql) {
        try (Statement statement = databaseConnector.getConnection().createStatement()) {
            statement.execute(sql);
        } catch (SQLException e) {
            throw new RuntimeException("Error executing SQL statement: ", e);
        }
    }

    public List<List<Object>> executeSelectQuery(String sql, Object... params) {
        List<List<Object>> resultList = new ArrayList<>();
    
        try (PreparedStatement statement = databaseConnector.getConnection().prepareStatement(sql)) {
            setParameters(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();
    
                // Process header row
                List<Object> headerColumns = new ArrayList<>();
                for (int i = 1; i <= columnCount; i++) {
                    headerColumns.add(metaData.getColumnName(i));
                }
    
                // Add header row only if there are data rows
                if (rs.next()) {
                    resultList.add(headerColumns);
    
                    // Process data rows
                    do {
                        List<Object> row = new ArrayList<>();
                        for (int i = 1; i <= columnCount; i++) {
                            row.add(rs.getObject(i));
                        }
                        resultList.add(row);
                    } while (rs.next());
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error executing select query: ", e);
        }
    
        return resultList;
    }

    public int executeInsertQuery(String sql, Object... params) {
        try (PreparedStatement statement = databaseConnector.getConnection().prepareStatement(sql)) {
            setParameters(statement, params);
            int rowsInserted = statement.executeUpdate();
            return rowsInserted;
        } catch (SQLException e) {
            throw new RuntimeException("Error executing insert query: ", e);
        }
    }

    private void setParameters(PreparedStatement statement, Object... params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            statement.setObject(i + 1, params[i]);
        }
    }
}
