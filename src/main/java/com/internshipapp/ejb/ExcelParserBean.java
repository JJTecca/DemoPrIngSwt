package com.internshipapp.ejb;

import com.internshipapp.common.InternshipApplicationDto;
import jakarta.ejb.Stateless;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.*;
import java.util.logging.Logger;

@Stateless
public class ExcelParserBean {
    private static final Logger LOG = Logger.getLogger(ExcelParserBean.class.getName());

    public List<Map<String, String>> parseExcel(InputStream inputStream) throws Exception {
        List<Map<String, String>> data = new ArrayList<>();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rowIterator = sheet.iterator();

            // SKIP FIRST 2 ROWS (header title and empty row)
            int rowCount = 0;
            while (rowIterator.hasNext() && rowCount < 2) {
                rowIterator.next();
                rowCount++;
                LOG.info("Skipped header row: " + rowCount);
            }

            // Now read headers (should be row 3 in Excel)
            if (!rowIterator.hasNext()) {
                throw new Exception("Excel file is empty after skipping header rows");
            }

            Row headerRow = rowIterator.next();
            List<String> headers = new ArrayList<>();

            for (Cell cell : headerRow) {
                String header = getCellValueAsString(cell).trim();
                headers.add(header);
            }

            LOG.info("Found headers: " + headers);
            LOG.info("Headers count: " + headers.size());

            // Read data rows (starting from row 4 in Excel)
            int dataRowCount = 0;
            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();
                Map<String, String> rowData = new HashMap<>();

                for (int i = 0; i < headers.size(); i++) {
                    Cell cell = row.getCell(i, Row.MissingCellPolicy.CREATE_NULL_AS_BLANK);
                    String value = getCellValueAsString(cell).trim();
                    rowData.put(headers.get(i), value);
                }

                // Skip completely empty rows
                if (!rowData.values().stream().allMatch(String::isEmpty)) {
                    data.add(rowData);
                    dataRowCount++;
                    // Debug: Log first few rows
                    if (dataRowCount <= 3) {
                        LOG.info("Row " + dataRowCount + " data: " + rowData);
                    }
                }
            }

        } catch (Exception e) {
            throw new Exception("Error parsing Excel: " + e.getMessage(), e);
        }

        LOG.info("Total rows parsed: " + data.size());
        return data;
    }

    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";

        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                if (DateUtil.isCellDateFormatted(cell)) {
                    return cell.getDateCellValue().toString();
                } else {
                    double num = cell.getNumericCellValue();
                    if (num == Math.floor(num)) {
                        return String.valueOf((int) num);
                    }
                    return String.valueOf(num);
                }
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }

    public byte[] createStudentExport(List<InternshipApplicationDto> apps) throws Exception {
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Grades Export");

            Row headerRow = sheet.createRow(0);
            headerRow.createCell(0).setCellValue("Nr. matricol");
            headerRow.createCell(1).setCellValue("Nota practica");

            CellStyle gradeStyle = workbook.createCellStyle();
            gradeStyle.setDataFormat(workbook.createDataFormat().getFormat("0.00"));

            int rowIndex = 1;
            for (InternshipApplicationDto app : apps) {
                Row row = sheet.createRow(rowIndex++);

                row.createCell(0).setCellValue(app.getStudentId());

                Cell gradeCell = row.createCell(1);
                if (app.getGrade() != null) {
                    gradeCell.setCellValue(app.getGrade());
                    gradeCell.setCellStyle(gradeStyle);
                }
            }

            sheet.autoSizeColumn(0);
            sheet.autoSizeColumn(1);

            workbook.write(out);
            return out.toByteArray();
        }
    }
}