package com.kabanchiktask;

import org.apache.commons.math3.stat.regression.SimpleRegression;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LinearRegressionHandler {
    private Map<String, List<SimpleRegression>> regressionsBySheet;
    private Map<String, List<List<Double[]>>> dataPointsBySheet;
    private List<String> sheetNames;
    private Workbook workbook;

    public LinearRegressionHandler() {
        regressionsBySheet = new HashMap<>();
        dataPointsBySheet = new HashMap<>();
        sheetNames = new ArrayList<>();
    }

    public void loadDataset(String filePath) throws IOException {
        FileInputStream fis = new FileInputStream(filePath);
        workbook = new XSSFWorkbook(fis);
    }

    public void runPredictions(int periods) {
        int numSheets = workbook.getNumberOfSheets();
        for (int i = 0; i < numSheets; i++) {
            Sheet sheet = workbook.getSheetAt(i);
            String sheetName = sheet.getSheetName();
            sheetNames.add(sheetName);
            processSheetData(sheet, periods, sheetName);
        }
    }

    public void savePredictions(String filePath) throws IOException {
        Workbook predictionWorkbook = new XSSFWorkbook();
    
        for (int i = 0; i < sheetNames.size(); i++) {
            String sheetName = sheetNames.get(i);
            Sheet sheet = predictionWorkbook.createSheet(sheetName);
    
            // Save column names
            Sheet originalSheet = workbook.getSheet(sheetName);
            Row firstRow = originalSheet.getRow(0);
            Row predictionRow = sheet.createRow(0);
            for (int j = 0; j < firstRow.getPhysicalNumberOfCells(); j++) {
                Cell cell = firstRow.getCell(j);
                Cell newCell = predictionRow.createCell(j);
                newCell.setCellValue(cell.getStringCellValue());
            }

            // Save data points and predictions for each column
            List<List<Double[]>> dataByColumns = dataPointsBySheet.get(sheetName);
            int maxDataSize = 0;
            for (List<Double[]> data : dataByColumns) {
                if (data.size() > maxDataSize) {
                    maxDataSize = data.size();
                }
            }
            int rowIndex = 1;
            for (int j = 0; j < maxDataSize; j++) {
                Row row = sheet.createRow(rowIndex);
                int colIndex = 0;
                for (int k = 0; k < dataByColumns.size(); k++) {
                    List<Double[]> data = dataByColumns.get(k);
                    if (j < data.size()) {
                        Double[] rowData = data.get(j);
                        for (int l = 0; l < rowData.length; l++) {
                            if ((colIndex > 0) & (l == 0)) {
                                continue;  // skip writing periods if it is already written before
                            }
                            Cell cell = row.createCell(colIndex + l);
                            cell.setCellValue(rowData[l]);
                        }
                    } else {
                        // Fill empty cells with blank values if there is no data for the column
                        for (int l = 0; l < dataByColumns.get(0).get(0).length; l++) {
                            Cell cell = row.createCell(colIndex + l);
                            cell.setCellValue("");
                        }
                    }
                    colIndex += 1;
                }
                rowIndex++;
            }
    
            // Save slope and intercept as a single human-readable string
            List<SimpleRegression> regressions = regressionsBySheet.get(sheetName);
            Row slopeInterceptRow = sheet.createRow(rowIndex + 1);
            for (int j = 0; j < regressions.size(); j++) {
                SimpleRegression regression = regressions.get(j);
                String slopeInterceptString = "Slope: " + regression.getSlope() + ", Intercept: " + regression.getIntercept();
                Cell cell = slopeInterceptRow.createCell(j + 1);
                cell.setCellValue(slopeInterceptString);
            }
        }
    
        FileOutputStream fos = new FileOutputStream(filePath);
        predictionWorkbook.write(fos);
    
        fos.close();
        predictionWorkbook.close();
    }
    
    private void processSheetData(Sheet sheet, int periods, String sheetName) {
        int numColumns = sheet.getRow(0).getPhysicalNumberOfCells();
        List<List<Double[]>> dataByColumns = new ArrayList<>();
        List<SimpleRegression> regressions = new ArrayList<>();

        for (int columnIndex = 1; columnIndex < numColumns; columnIndex++) {
            List<Double> data = extractDataFromColumn(sheet, columnIndex);
            SimpleRegression regression = createRegression(data);
            regressions.add(regression);
            List<Double[]> dataPoints = extendWithPredictions(data, regression, periods);

            // Store data points for each column
            dataByColumns.add(dataPoints);
        }

        regressionsBySheet.put(sheetName, regressions);
        dataPointsBySheet.put(sheetName, dataByColumns);
    }

    private List<Double> extractDataFromColumn(Sheet sheet, int columnIndex) {
        List<Double> data = new ArrayList<>();
        for (Row row : sheet) {
            Cell cellValue = row.getCell(columnIndex);
            if (cellValue != null && cellValue.getCellType() == CellType.NUMERIC) {
                data.add(cellValue.getNumericCellValue());
            }
        }
        return data;
    }

    private SimpleRegression createRegression(List<Double> data) {
        SimpleRegression regression = new SimpleRegression();
        for (int i = 0; i < data.size(); i++) {
            regression.addData(i, data.get(i));
        }
        return regression;
    }

    private List<Double[]> extendWithPredictions(List<Double> data, SimpleRegression regression, int periods) {
        List<Double[]> dataPoints = new ArrayList<>();
        for (int i = 0; i < data.size(); i++) {
            dataPoints.add(new Double[]{(double) i, data.get(i)});
        }

        // Add future predictions
        for (int i = 1; i <= periods; i++) {
            double nextTime = data.size() + i;
            double nextValue = regression.predict(nextTime);
            dataPoints.add(new Double[]{nextTime, nextValue});
        }

        return dataPoints;
    }
}
