package com.kabanchiktask;

public class Main {
    public static void main(String[] args) {
        // runETL();
        // runAggregations();
        runLinearRegression();
    }

    private static void runETL() {
        // Load connection properties
        String host = PropertiesLoader.getProperty("db.host");
        int port = Integer.parseInt(PropertiesLoader.getProperty("db.port"));
        String dbName = PropertiesLoader.getProperty("db.name");
        String username = PropertiesLoader.getProperty("db.user");
        String password = PropertiesLoader.getProperty("db.password");

        // Establish connection, execute queries and run ETL
        try (DatabaseConnector databaseConnector = new DatabaseConnector(host, port, dbName, username, password)) {
            String sqlScriptsDirectory = PropertiesLoader.getProperty("db.sqlScriptsDirectory");
            DatabaseManager databaseManager = new DatabaseManager(databaseConnector, sqlScriptsDirectory);

            // Create schema
            String createSchemaSQL = databaseManager.readSqlScript("create_schema.sql");
            databaseManager.executeSQL(createSchemaSQL);

            // Add initial data
            String insertGameEventInitialDataSQL = databaseManager.readSqlScript("insert_game_event_initial_data.sql");
            databaseManager.executeInsertQuery(insertGameEventInitialDataSQL);

            // Run ETL
            DataHandler dataHandler = new DataHandler(databaseManager);
            String resourcesPath = PropertiesLoader.getProperty("db.dataDirectory");
            dataHandler.handleData(resourcesPath);
        } catch (Exception e) {
            throw new RuntimeException("An error occurred while executing Main operations", e);
        }
    }

    private static void runAggregations() {
        // Load connection properties
        String host = PropertiesLoader.getProperty("db.host");
        int port = Integer.parseInt(PropertiesLoader.getProperty("db.port"));
        String dbName = PropertiesLoader.getProperty("db.name");
        String username = PropertiesLoader.getProperty("db.user");
        String password = PropertiesLoader.getProperty("db.password");

        // Establish connection and create file with aggregations
        try (DatabaseConnector databaseConnector = new DatabaseConnector(host, port, dbName, username, password)) {
            String aggsqlDirectoryPath = PropertiesLoader.getProperty("db.aggSqlScriptsDirectory");
            DatabaseManager databaseManager = new DatabaseManager(databaseConnector, aggsqlDirectoryPath);

            // Create an excel file with aggregations
            String outputFilePath = aggsqlDirectoryPath + "output.xlsx";
            AggregationHandler aggregationHandler = new AggregationHandler(databaseManager, outputFilePath);
            aggregationHandler.generateExcelFile();
        } catch (Exception e) {
            throw new RuntimeException("An error occurred while executing Main operations", e);
        }
    }

    private static void runLinearRegression() {
        String datasetFilePath = PropertiesLoader.getProperty("lr.dataFilePath");
        String outputFile = PropertiesLoader.getProperty("lr.outputFilePath");
        int predictionPeriod = 6 * 30;

        try {
            LinearRegressionHandler linearRegressionHandler = new LinearRegressionHandler();

            // Preload data
            linearRegressionHandler.loadDataset(datasetFilePath);

            // Run predictions
            linearRegressionHandler.runPredictions(predictionPeriod);

            // Save predictions
            linearRegressionHandler.savePredictions(outputFile);
        } catch (Exception e) {
            throw new RuntimeException("An error occurred while executing Main operations", e);
        }
    }
}
