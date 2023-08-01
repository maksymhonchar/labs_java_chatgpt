package com.kabanchiktask;

import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;
import com.opencsv.exceptions.CsvValidationException;
import smile.clustering.KMeans;

import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class KMeansClusterizationHandler {
    private List<String[]> dataset = new ArrayList<>();
    private int[] clusteredData;

    public void loadDataset(String filePath) throws IOException {
        try (CSVReader reader = new CSVReader(new FileReader(filePath))) {
            String[] nextLine;
            try {
                boolean isFirstRow = true;
                while ((nextLine = reader.readNext()) != null) {
                    if (isFirstRow) {
                        isFirstRow = false;
                        continue;
                    }
                    dataset.add(new String[]{nextLine[0], nextLine[1]}); // Assuming ID is at index 0 and data is at index 1
                }
            } catch (CsvValidationException e) {
                throw new RuntimeException("Error occurred while reading the CSV file:", e);
            }
        }
    }

    public void runClusterization(int k) {
        // Filtering out rows with values equal to 0
        List<double[]> filteredData = new ArrayList<>();
        for (int i = 0; i < dataset.size(); i++) {
            String[] row = dataset.get(i);
            double value = Double.parseDouble(row[1]); // Extracting data from the second column
            if (value != 0) {
                filteredData.add(new double[]{value});
            }
        }

        // Convert the filtered data list to a double array for clustering
        double[][] data = filteredData.toArray(new double[0][]);

        KMeans kmeans = KMeans.fit(data, k);
        clusteredData = kmeans.y;
    }

    public void saveClusteredData(String filePath) throws IOException {
        try (CSVWriter writer = new CSVWriter(new FileWriter(filePath))) {
            for (int i = 0, j = 0; i < dataset.size(); i++) {
                String[] row = dataset.get(i);
                String[] newRow = new String[row.length + 1];
                System.arraycopy(row, 0, newRow, 0, row.length);

                // Skip rows with values equal to 0
                if (Double.parseDouble(row[1]) == 0) {
                    newRow[row.length] = "0";
                } else {
                    newRow[row.length] = Integer.toString(clusteredData[j] + 1); // +1 for cluster
                    j++;
                }
                writer.writeNext(newRow);
            }
        }
    }
}
