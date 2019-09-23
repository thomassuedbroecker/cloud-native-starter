package com.ibm.webapi.data;

public class NoConnectivity extends Exception {

	private static final long serialVersionUID = 1L;

	public NoConnectivity() {
	}

	public NoConnectivity(String message) {
		super(message);
	}
	
	public NoConnectivity(Throwable cause) {
		super(cause);
	}
}
