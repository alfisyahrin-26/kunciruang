package com.kampus.kunciruang.seeder;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DatabaseSeeder implements CommandLineRunner {

    @Override
    public void run(String... args) throws Exception {
        System.out.println("DatabaseSeeder dinonaktifkan. Data diambil langsung dari tabel Laravel.");
    }
}
