package com.vku.karaoke.utils;

import com.vku.karaoke.model.Song;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class FileIOUtil {
    private FileIOUtil() {
    }

    public static void saveSongsToTxt(List<Song> songs, String filePath) throws Exception {
        Path path = Path.of(filePath);

        try (BufferedWriter writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
            for (Song song : songs) {
                writer.write(song.getId() + "|" + song.getTitle() + "|" + song.getArtist() + "|" + song.getGenre());
                writer.newLine();
            }
        }
    }

    public static List<Song> loadSongsFromTxt(String filePath) throws Exception {
        List<Song> songs = new ArrayList<>();
        Path path = Path.of(filePath);

        if (!Files.exists(path)) {
            return songs;
        }

        try (BufferedReader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            String line;

            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\|", -1);

                if (parts.length == 4) {
                    songs.add(new Song(
                            parts[0].trim(),
                            parts[1].trim(),
                            parts[2].trim(),
                            parts[3].trim()
                    ));
                }
            }
        }

        return songs;
    }
}
