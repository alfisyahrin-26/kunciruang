package com.kampus.kunciruang.exception;

public class QrExpiredException extends RuntimeException {
    public QrExpiredException(String message) {
        super(message);
    }
}
