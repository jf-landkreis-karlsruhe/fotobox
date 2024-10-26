package de.fw.fotobox.controller;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class UserPictureController {

    @Value("${folder.path}")
    private String folderPath;

    @Value("${file.type}")
    private String fileType;

    private boolean isValidId(String id) {
        String regex = "^[a-zA-Z0-9_-]+$";
        return id != null && id.matches(regex);
    }

    @GetMapping(value = "/getPictureListById/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<String>> getPictureListById(@PathVariable String id) {
        if (!isValidId(id)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Arrays.asList("Invalid code format: " + id));
        }

        File dir = new File(folderPath + "/" + id);

        if (!dir.exists() || !dir.isDirectory() || dir.listFiles() == null || dir.listFiles().length == 0) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Arrays.asList("No pictures found for code: " + id));
        }

        // Collect list of image URLs
        List<String> imageUrls = Arrays.stream(dir.listFiles())
                .filter(file -> file.isFile() && file.getName().endsWith("." + fileType))
                .map(file -> "/getPictureById/" + id + "/" + file.getName())
                .collect(Collectors.toList());

        return ResponseEntity.ok(imageUrls);
    }

    @GetMapping(value = "/getPictureById/{id}", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<Resource> getPicturesById(@PathVariable String id) throws IOException {
        if (!isValidId(id)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ByteArrayResource(("Invalid code format: " + id).getBytes()));
        }

        File dir = new File(folderPath + "/" + id);

        if (!dir.exists() || !dir.isDirectory() || dir.listFiles() == null || dir.listFiles().length == 0) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new ByteArrayResource(("No pictures found for code: " + id).getBytes()));
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos)) {
            for (File file : dir.listFiles()) {
                if (file.isFile() && file.getName().endsWith("." + fileType)) {
                    zos.putNextEntry(new ZipEntry(file.getName()));
                    Files.copy(file.toPath(), zos);
                    zos.closeEntry();
                }
            }
        }

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + id + ".zip");

        return ResponseEntity.ok()
                .headers(headers)
                .contentLength(baos.size())
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .body(new ByteArrayResource(baos.toByteArray()));
    }


    @GetMapping(value = "/getPictureById/{id}/{fileName}", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<Resource> getPictureByIdAndFileName(@PathVariable String id, @PathVariable String fileName)
            throws IOException {
        if (!isValidId(id) || fileName == null || fileName.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(null);
        }

        File file = new File(folderPath + "/" + id + "/" + fileName);
        if (!file.exists() || !file.isFile()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }

        String mimeType = Files.probeContentType(file.toPath());
        if (mimeType == null) {
            mimeType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
        }

        InputStreamResource resource = new InputStreamResource(Files.newInputStream(file.toPath()));

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(mimeType))
                .body(resource);
    }
}
