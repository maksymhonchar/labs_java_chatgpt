package com.kabanchiktask;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class AggregationHandler {
    private DatabaseManager databaseManager;
    private String outputFilePath;

    public AggregationHandler(DatabaseManager databaseManager, String outputFilePath) {
        this.databaseManager = databaseManager;
        this.outputFilePath = outputFilePath;
    }

    public void generateExcelFile() {
        Workbook workbook = new XSSFWorkbook();

        try {
            List<Path> sqlFiles = getSQLFiles();
            for (Path sqlFile : sqlFiles) {
                String filename = sqlFile.getFileName().toString();
                String sql = databaseManager.readSqlScript(filename);
                List<List<Object>> resultSet = databaseManager.executeSelectQuery(sql);
                createSheet(workbook, filename, resultSet);
            }

            saveWorkbook(workbook);
        } catch (IOException e) {
            throw new RuntimeException("Error generating Excel file: " + e.getMessage(), e);
        }
    }

    private List<Path> getSQLFiles() throws IOException {
        List<String> sqlFilePaths = new ArrayList<>();
        String sqlDirectoryPath = databaseManager.getDirectoryPath();
        String absoluteResourcesPath = getClass().getClassLoader().getResource(sqlDirectoryPath).getPath();
        File directory = new File(absoluteResourcesPath);

        if (directory.exists() && directory.isDirectory()) {
            File[] files = directory.listFiles();

            if (files != null) {
                for (File file : files) {
                    if (file.isFile() && file.getName().endsWith(".sql")) {
                        sqlFilePaths.add(sqlDirectoryPath + file.getName());
                    }
                }
            }
        }

        List<Path> sqlFiles = new ArrayList<>();
        for (String filePath : sqlFilePaths) {
            sqlFiles.add(Paths.get(filePath));
        }

        return sqlFiles;
    }

    private void createSheet(Workbook workbook, String sheetName, List<List<Object>> resultSet) {
        Sheet sheet = workbook.createSheet(sheetName);
    
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        CellStyle headerCellStyle = workbook.createCellStyle();
        headerCellStyle.setFont(headerFont);
    
        for (int rowIndex = 0; rowIndex <= resultSet.size(); rowIndex++) {
            if (rowIndex == 0) {
                Row headerRow = sheet.createRow(0);
                List<Object> headerColumns = resultSet.get(0);
                for (int i = 0; i < headerColumns.size(); i++) {
                    Cell cell = headerRow.createCell(i);
                    cell.setCellValue(headerColumns.get(i).toString());
                    cell.setCellStyle(headerCellStyle);
                }
                continue;
            } else {
                Row row = sheet.createRow(rowIndex);
                List<Object> rowData = resultSet.get(rowIndex - 1);
                for (int columnIndex = 0; columnIndex < rowData.size(); columnIndex++) {
                    Cell cell = row.createCell(columnIndex);
                    Object value = rowData.get(columnIndex);
                    if (value instanceof Number) {
                        cell.setCellValue(((Number) value).doubleValue());
                    } else {
                        cell.setCellValue(value.toString());
                    }
                }
            }
        }
    }

    private void saveWorkbook(Workbook workbook) throws IOException {
        File outputFile = new File(outputFilePath);
        File outputDirectory = outputFile.getParentFile();

        if (outputDirectory != null && !outputDirectory.exists()) {
            if (!outputDirectory.mkdirs()) {
                throw new IOException("Failed to create output directory: " + outputDirectory.getAbsolutePath());
            }
        }

        try (FileOutputStream outputStream = new FileOutputStream(outputFile)) {
            workbook.write(outputStream);
        }
    }
}
