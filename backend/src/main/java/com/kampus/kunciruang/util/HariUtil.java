package com.kampus.kunciruang.util;

import java.time.DayOfWeek;

public class HariUtil {

    public static String toIndonesian(DayOfWeek day) {
        return switch (day) {
            case MONDAY    -> "Senin";
            case TUESDAY   -> "Selasa";
            case WEDNESDAY -> "Rabu";
            case THURSDAY  -> "Kamis";
            case FRIDAY    -> "Jumat";
            case SATURDAY  -> "Sabtu";
            case SUNDAY    -> "Minggu";
        };
    }
}
