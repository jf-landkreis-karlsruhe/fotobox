package de.fw.fotobox.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import de.fw.fotobox.model.SessionRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.nio.file.Path;
import java.security.SecureRandom;
import java.util.List;

@CrossOrigin(origins = "https://localhost:8080")
@RestController
@RequestMapping("/savesession")
public class SessionController {

	private static final int PORT = 8080;
	private static final String HTTP_HEAD = "http://";
	private static final String ALPHANUMERIC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	private static final int CODE_LENGTH = 8;

	@Value("${folder.path}")
	private String storagePath;

	@Value("${cryption.key}")
	private String cryptionKey;

	@Value("${file.type}")
	private String fileType;

	@Value("${session.ip}")
	private String sessionIp;

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
		
		try {

			extractImages(response, images, uniqueCode, uniqueFolder);
		} catch (IOException e) {
			response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
			return "Fehler beim Speichern der Bilder";
		}
		String ip = sessionIp.equals("localadress") ? getLocalIPAddress() : sessionIp;

		response.setStatus(HttpServletResponse.SC_OK);
		return HTTP_HEAD + ip + ":" + PORT + "/?code=" + uniqueCode;
	}

	private void extractImages(HttpServletResponse response, List<List<Byte>> images, String uniqueCode,
			File uniqueFolder) throws IOException {
		for (int i = 0; i < images.size(); i++) {
			List<Byte> imageBytes = images.get(i);
			File imageFile = new File(uniqueFolder, uniqueCode + "_image_" + (i + 1) + "." + fileType);

			try (FileOutputStream fos = new FileOutputStream(imageFile)) {
				for (byte b : imageBytes) {
					fos.write(b);
				}
			}
		}
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

	public String getLocalIPAddress() {
		try {
			InetAddress localHost = InetAddress.getLocalHost();
			return localHost.getHostAddress();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "localhost";
	}

}