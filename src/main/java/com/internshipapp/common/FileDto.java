package com.internshipapp.common;

public class FileDto {
    private String fileName;
    private String contentType;
    private byte[] fileData;

    public FileDto(String fileName, String contentType, byte[] fileData) {
        this.fileName = fileName;
        this.contentType = contentType;
        this.fileData = fileData;
    }

    public String getFileName() {
        return fileName;
    }

    public String getContentType() {
        return contentType;
    }

    public byte[] getFileData() {
        return fileData;
    }
}