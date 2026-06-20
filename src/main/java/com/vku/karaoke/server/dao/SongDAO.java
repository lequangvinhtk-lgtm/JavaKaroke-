package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.Song;
import com.vku.karaoke.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SongDAO {
    public List<Song> getAllSongs() throws Exception {
        List<Song> songs = new ArrayList<>();
        String sql = "SELECT id, title, artist, genre FROM songs ORDER BY id";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                songs.add(mapSong(rs));
            }
        }

        return songs;
    }

    public List<Song> searchSongs(String keyword) throws Exception {
        List<Song> songs = new ArrayList<>();
        String sql = """
                SELECT id, title, artist, genre
                FROM songs
                WHERE id LIKE ? OR title LIKE ? OR artist LIKE ? OR genre LIKE ?
                ORDER BY title
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            String like = "%" + keyword + "%";
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            ps.setString(4, like);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    songs.add(mapSong(rs));
                }
            }
        }

        return songs;
    }

    public boolean addSong(Song song) throws Exception {
        String sql = "INSERT INTO songs(id, title, artist, genre) VALUES (?, ?, ?, ?)";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            fillSongParams(ps, song);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateSong(Song song) throws Exception {
        String sql = "UPDATE songs SET title = ?, artist = ?, genre = ? WHERE id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, song.getTitle());
            ps.setString(2, song.getArtist());
            ps.setString(3, song.getGenre());
            ps.setString(4, song.getId());

            return ps.executeUpdate() > 0;
        }
    }

    public boolean upsertSong(Song song) throws Exception {
        String sql = """
                INSERT INTO songs(id, title, artist, genre)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    title = VALUES(title),
                    artist = VALUES(artist),
                    genre = VALUES(genre)
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            fillSongParams(ps, song);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deleteSong(String id) throws Exception {
        String sql = "DELETE FROM songs WHERE id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    private void fillSongParams(PreparedStatement ps, Song song) throws Exception {
        ps.setString(1, song.getId());
        ps.setString(2, song.getTitle());
        ps.setString(3, song.getArtist());
        ps.setString(4, song.getGenre());
    }

    private Song mapSong(ResultSet rs) throws Exception {
        return new Song(
                rs.getString("id"),
                rs.getString("title"),
                rs.getString("artist"),
                rs.getString("genre")
        );
    }
}
