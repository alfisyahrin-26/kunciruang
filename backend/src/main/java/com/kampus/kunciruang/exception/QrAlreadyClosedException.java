package com.kampus.kunciruang.exception;

public class QrAlreadyClosedException extends RuntimeException {
    public QrAlreadyClosedException(String message) {
        super(message);
    }
}
