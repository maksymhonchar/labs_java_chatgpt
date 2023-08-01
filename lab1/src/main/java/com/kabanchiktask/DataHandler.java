package com.kabanchiktask;

import com.google.gson.JsonArray;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class DataHandler {
    private final DataExtractor extractor;
    private final DataTransformer transformer;
    private final DataLoader loader;

    public DataHandler(DatabaseManager databaseManager) {
        this.extractor = new DataExtractor();
        this.transformer = new DataTransformer();
        this.loader = new DataLoader(databaseManager);
    }

    public void handleData(String resourcesPath) {
        if (resourcesPath == null || resourcesPath.isEmpty()) {
            throw new IllegalArgumentException("Resources path cannot be null or empty.");
        }

        String suffix = "-15";  // extract only yyyy-MM-dd-suffix.json
        System.out.println("Working with suffix: " + suffix);
        List<String> jsonFiles = extractor.getAllJSONFilesInDirectory(resourcesPath, suffix);

        for (String jsonFilePath : jsonFiles) {
            logDebugMessage("Handling file:", jsonFilePath);

            // extract
            long startTime = System.currentTimeMillis();
            JsonArray jsonArray = extractor.extractData(jsonFilePath);
            long extractionTime = System.currentTimeMillis() - startTime;
            logDebugMessage("Extraction completed in", extractionTime, "ms");

            // transform
            startTime = System.currentTimeMillis();
            Map<Integer, List<Map<String, Object>>> transformedData = transformer.transformData(jsonArray);
            long transformationTime = System.currentTimeMillis() - startTime;
            logDebugMessage("Transformation completed in", transformationTime, "ms");

            // load
            startTime = System.currentTimeMillis();
            loader.loadData(transformedData);
            long loadingTime = System.currentTimeMillis() - startTime;
            logDebugMessage("Loading completed in", loadingTime, "ms", "\n");
        }
    }

    private void logDebugMessage(Object... objects) {
        String logMessage = String.format("[DBG] [" + LocalDateTime.now() + "]");
        for (Object obj : objects) {
            logMessage += " " + obj;
        }
        System.out.println(logMessage);
    }
}
