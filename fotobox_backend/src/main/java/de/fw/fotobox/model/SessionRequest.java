package de.fw.fotobox.model;

import java.util.List;

public class SessionRequest {
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