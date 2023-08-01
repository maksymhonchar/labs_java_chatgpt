package com.kabanchiktask;

import java.io.IOException;

public class Main {
    public static void main(String[] args) {
        // runClusterization();
        // runAggregations();
        runLinearRegression();
    }

    private static void runClusterization() {
        KMeansClusterizationHandler handler = new KMeansClusterizationHandler();

        try {
            // Load dataset from Excel file.
            String datasetFilePath = PropertiesLoader.getProperty("cs.datasetFilePath");
            handler.loadDataset(datasetFilePath);

            // Perform clustering with k = 3.
            int k_clusters = 3;
            handler.runClusterization(k_clusters);

            // Save clustered data to a new Excel file.
            String outputFilePath = PropertiesLoader.getProperty("cs.outputFilePath");
            handler.saveClusteredData(outputFilePath);
        } catch (IOException e) {
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
            e.printStackTrace();
            throw new RuntimeException("An error occurred while executing Main operations", e);
        }
    }

}
