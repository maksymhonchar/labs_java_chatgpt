package com.kabanchiktask;

import com.google.gson.Gson;
import com.google.gson.JsonArray;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public class DataExtractor {
    public JsonArray extractData(String jsonFilePath) {
        try (InputStream inputStream = getClass().getClassLoader().getResourceAsStream(jsonFilePath)) {
            if (inputStream == null) {
                throw new IOException("File " + jsonFilePath + " not found in resources");
            }
            return new Gson().fromJson(new InputStreamReader(inputStream, StandardCharsets.UTF_8), JsonArray.class);
        } catch (IOException e) {
            throw new RuntimeException("Failed to read JSON file", e);
        }
    }

    public List<String> getAllJSONFilesInDirectory(String resourcesPath, String suffix) {
        List<String> jsonFilePaths = new ArrayList<>();
        String absoluteResourcesPath = getClass().getClassLoader().getResource(resourcesPath).getPath();
        File directory = new File(absoluteResourcesPath);

        if (directory.exists() && directory.isDirectory()) {
            File[] files = directory.listFiles();

            if (files != null) {
                for (File file : files) {
                    if (file.isFile() && file.getName().endsWith(suffix + ".json")) {
                        jsonFilePaths.add(resourcesPath + file.getName());
                    }
                }
            }
        }

        return jsonFilePaths;
    }
}
