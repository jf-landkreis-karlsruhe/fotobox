package de.fw.fotobox.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.security.SecureRandom;
import java.util.List;

@CrossOrigin(origins = "http://localhost:8080")
@RestController
@RequestMapping("/savesession")
public class SessionController {

	@Value("${folder.path}")
	private String storagePath;

	@Value("${cryption.key}")
	private String cryptionKey;

	@Value("${file.type}")
	private String fileType;
	
	@Value("${session.ip}")
	private String sessionIp;
	
	
	

	private static final String ALPHANUMERIC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	private static final int CODE_LENGTH = 8;

	@PostMapping
	public String saveSession(@RequestBody SessionRequest sessionRequest, HttpServletResponse response) {
		String token = sessionRequest.getToken();
		if (!cryptionKey.equals(token)) {
			response.setStatus(HttpServletResponse.SC_FORBIDDEN);
			return "Ungültiger Schlüssel";
		}

		List<List<Byte>> images = sessionRequest.getImages();

		String uniqueCode = generateUniqueCode();

		Path uniqueFolderPath = Path.of(storagePath, uniqueCode);
		File uniqueFolder = new File(uniqueFolderPath.toString());
		if (!uniqueFolder.exists() && !uniqueFolder.mkdirs()) {
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			return "Fehler beim Erstellen des Ordners";
		}

		for (int i = 0; i < images.size(); i++) {
			List<Byte> imageBytes = images.get(i);
			File imageFile = new File(uniqueFolder, uniqueCode + "_image_" + (i + 1) + "." + fileType);

			try (FileOutputStream fos = new FileOutputStream(imageFile)) {
				for (byte b : imageBytes) {
					fos.write(b);
				}
			} catch (IOException e) {
				response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
				return "Fehler beim Speichern von Bild " + (i + 1);
			}
		}

		response.setStatus(HttpServletResponse.SC_OK);
		return sessionIp + ":8080/?code=" + uniqueCode;
	}

	private String generateUniqueCode() {
		String code;
		File uniqueFolder;
		do {
			code = generateShortCode();
			uniqueFolder = new File(storagePath, code);
		} while (uniqueFolder.exists());
		return code;
	}

	private String generateShortCode() {
		SecureRandom random = new SecureRandom();
		StringBuilder code = new StringBuilder(CODE_LENGTH);
		for (int i = 0; i < CODE_LENGTH; i++) {
			code.append(ALPHANUMERIC.charAt(random.nextInt(ALPHANUMERIC.length())));
		}
		return code.toString();
	}

	public static class SessionRequest {
		private String token;
		private List<List<Byte>> images;

		public String getToken() {
			return token;
		}

		public void setToken(String token) {
			this.token = token;
		}

		public List<List<Byte>> getImages() {
			return images;
		}

		public void setImages(List<List<Byte>> images) {
			this.images = images;
		}
	}
}