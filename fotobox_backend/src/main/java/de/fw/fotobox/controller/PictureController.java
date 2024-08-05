package de.fw.fotobox.controller;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class PictureController {

	@Value("${folder.path}")
	private String folderPath;

	@Value("${file.type}")
	private String fileType;

	@GetMapping(value = "/getPictureById/{id}", produces = MediaType.APPLICATION_OCTET_STREAM_VALUE)
	public ResponseEntity<Resource> getPicturesById(@PathVariable String id) throws IOException {
	    if (!isValidId(id)) {
	        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
	                .body(new ByteArrayResource(("Invalid code format: " + id).getBytes()));
	    }

	    File dir = new File(folderPath + "/" + id);

	    if (!dir.exists() || !dir.isDirectory() || dir.listFiles() == null || dir.listFiles().length == 0) {
	        return ResponseEntity.status(HttpStatus.NOT_FOUND)
	                .body(new ByteArrayResource(("Ungültiger Code: " + id).getBytes()));
	    }

		File zipFile = File.createTempFile(id, ".zip");

		try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(zipFile))) {
			for (File file : dir.listFiles()) {
				if (file.isFile() && file.getName().endsWith("." + fileType)) {
					zos.putNextEntry(new ZipEntry(file.getName()));
					Files.copy(file.toPath(), zos);
					zos.closeEntry();
				}
			}
		}

		Path path = Paths.get(zipFile.getAbsolutePath());
		ByteArrayResource resource = new ByteArrayResource(Files.readAllBytes(path));

		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + LocalDateTime.now().toString() + ".zip");

		return ResponseEntity.ok().headers(headers).contentLength(zipFile.length())
				.contentType(MediaType.APPLICATION_OCTET_STREAM).body(resource);
	}
	

	

	@GetMapping("/admin/allPictures")
	public ResponseEntity<Resource> getAllPictures() throws IOException {
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
		ZipOutputStream zipOutputStream = new ZipOutputStream(byteArrayOutputStream);

		Path sourcePath = Paths.get(folderPath);
		Files.walk(sourcePath).filter(path -> !Files.isDirectory(path)).forEach(path -> {
			ZipEntry zipEntry = new ZipEntry(sourcePath.relativize(path).toString());
			try {
				zipOutputStream.putNextEntry(zipEntry);
				Files.copy(path, zipOutputStream);
				zipOutputStream.closeEntry();
			} catch (IOException e) {
				e.printStackTrace();
			}
		});

		zipOutputStream.finish();
		zipOutputStream.close();

		ByteArrayResource resource = new ByteArrayResource(byteArrayOutputStream.toByteArray());
		HttpHeaders headers = new HttpHeaders();
		headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=all_pictures.zip");

		return ResponseEntity.ok().headers(headers).contentLength(resource.contentLength())
				.contentType(MediaType.APPLICATION_OCTET_STREAM).body(resource);
	}
	
	@GetMapping("/admin/stats")
    @ResponseBody
    public ResponseEntity<String> getFolderStats() {
        long fileCount = 0;
        long folderCount = 0;

        try {
            fileCount = Files.walk(Paths.get(folderPath))
                .filter(Files::isRegularFile)
                .count();

            folderCount = Files.walk(Paths.get(folderPath))
                .filter(Files::isDirectory)
                .count() - 1;
        } catch (IOException e) {
            e.printStackTrace();
        }

        String stats = String.format("Anzahl der gespeicherten Bilder: %d\nAnzahl der Ordner %d", fileCount, folderCount);
        return ResponseEntity.ok(stats);
    }

	@GetMapping("/admin")
	public String adminPage() {
		return "admin";
	}

	@GetMapping("/login")
	public String loginPage(Model model, String error, String logout) {
		if (error != null) {
			model.addAttribute("errorMsg", "Invalid username or password.");
		}
		if (logout != null) {
			model.addAttribute("msg", "You have been logged out successfully.");
		}
		return "login";
	}

	@GetMapping("/access-denied")
	public String accessDenied() {
		return "access-denied";
	}
	

	private boolean isValidId(String id) {
	    String regex = "^[a-zA-Z0-9_-]+$";
	    return id != null && id.matches(regex);
	}
	
}
