package com.kabanchiktask;

import org.apache.commons.math3.stat.regression.SimpleRegression;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class LinearRegressionHandler {
    private List<SimpleRegression> regressions;
    private List<List<Double[]>> dataPoints;
    private List<String> sheetNames;
    private Workbook workbook;

    public LinearRegressionHandler() {
        regressions = new ArrayList<>();
        dataPoints = new ArrayList<>();
        sheetNames = new ArrayList<>();
    }

    public void loadDataset(String filePath) throws IOException {
        FileInputStream fis = new FileInputStream(filePath);
        workbook = new XSSFWorkbook(fis);
    }

    public void runPredictions(int periods) {
        for (Sheet sheet : workbook) {
            sheetNames.add(sheet.getSheetName());
            List<Double> data = extractDataFromSheet(sheet);
            SimpleRegression regression = createRegression(data);
            regressions.add(regression);
            extendWithPredictions(data, regression, periods);
        }
    }

    public void savePredictions(String filePath) throws IOException {
        Workbook predictionWorkbook = new XSSFWorkbook();

        for (int i = 0; i < regressions.size(); i++) {
            Sheet sheet = predictionWorkbook.createSheet(sheetNames.get(i));

            // Save column names
            Sheet originalSheet = workbook.getSheetAt(i);
            Row firstRow = originalSheet.getRow(0);
            Row predictionRow = sheet.createRow(0);
            for (int j = 0; j < firstRow.getPhysicalNumberOfCells(); j++) {
                Cell cell = firstRow.getCell(j);
                Cell newCell = predictionRow.createCell(j);
                newCell.setCellValue(cell.getStringCellValue());
            }

            // Save data points
            List<Double[]> data = dataPoints.get(i);
            for (int j = 0; j < data.size(); j++) {
                Row row = sheet.createRow(j+1);
                row.createCell(0).setCellValue(data.get(j)[0]); // index or time
                row.createCell(1).setCellValue(data.get(j)[1]); // value or predicted value
            }

            // Save slope and intercept
            SimpleRegression regression = regressions.get(i);
            Row row = sheet.createRow(data.size()+1);
            row.createCell(0).setCellValue("Slope");
            row.createCell(1).setCellValue(regression.getSlope());
            row = sheet.createRow(data.size() + 2);
            row.createCell(0).setCellValue("Intercept");
            row.createCell(1).setCellValue(regression.getIntercept());
        }

        FileOutputStream fos = new FileOutputStream(filePath);
        predictionWorkbook.write(fos);

        fos.close();
        predictionWorkbook.close();
    }

    private List<Double> extractDataFromSheet(Sheet sheet) {
        List<Double> data = new ArrayList<>();
        for (Row row : sheet) {
            Cell cellValue = row.getCell(1); // 1 means data is in "B" column
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

    private void extendWithPredictions(List<Double> data, SimpleRegression regression, int periods) {
        List<Double[]> dataWithPredictions = new ArrayList<>();
        // Add existing data points
        for (int i = 0; i < data.size(); i++) {
            dataWithPredictions.add(new Double[]{(double) i, data.get(i)});
        }
        // Add future predictions
        for (int i = 1; i <= periods; i++) {
            double nextTime = data.size() + i;
            double nextValue = regression.predict(nextTime);
            dataWithPredictions.add(new Double[]{nextTime, nextValue});
        }
        dataPoints.add(dataWithPredictions);
    }
}
