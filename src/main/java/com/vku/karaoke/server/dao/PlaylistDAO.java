package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.Playlist;
import com.vku.karaoke.model.Song;
import com.vku.karaoke.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PlaylistDAO {
    public List<Playlist> findByUser(int userId) throws Exception {
        List<Playlist> playlists = new ArrayList<>();
        String sql = "SELECT id, user_id, name, created_at FROM playlists WHERE user_id = ? ORDER BY created_at DESC";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    playlists.add(new Playlist(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getString("name"),
                            String.valueOf(rs.getTimestamp("created_at"))
                    ));
                }
            }
        }

        return playlists;
    }

    public boolean createPlaylist(int userId, String name) throws Exception {
        String sql = "INSERT INTO playlists(user_id, name) VALUES (?, ?)";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, name);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean deletePlaylist(int userId, int playlistId) throws Exception {
        String sql = "DELETE FROM playlists WHERE id = ? AND user_id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, playlistId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean addSongToPlaylist(int userId, int playlistId, String songId) throws Exception {
        String sql = """
                INSERT IGNORE INTO playlist_songs(playlist_id, song_id)
                SELECT id, ?
                FROM playlists
                WHERE id = ? AND user_id = ?
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setString(1, songId);
            ps.setInt(2, playlistId);
            ps.setInt(3, userId);

            return ps.executeUpdate() > 0;
        }
    }

    public boolean removeSongFromPlaylist(int userId, int playlistId, String songId) throws Exception {
        String sql = """
                DELETE ps
                FROM playlist_songs ps
                JOIN playlists p ON ps.playlist_id = p.id
                WHERE ps.playlist_id = ?
                  AND p.user_id = ?
                  AND ps.song_id = ?
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, playlistId);
            ps.setInt(2, userId);
            ps.setString(3, songId);

            return ps.executeUpdate() > 0;
        }
    }

    public List<Song> getSongsInPlaylist(int userId, int playlistId) throws Exception {
        List<Song> songs = new ArrayList<>();
        String sql = """
                SELECT s.id, s.title, s.artist, s.genre
                FROM songs s
                JOIN playlist_songs ps ON s.id = ps.song_id
                JOIN playlists p ON ps.playlist_id = p.id
                WHERE p.id = ? AND p.user_id = ?
                ORDER BY s.title
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, playlistId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    songs.add(new Song(
                            rs.getString("id"),
                            rs.getString("title"),
                            rs.getString("artist"),
                            rs.getString("genre")
                    ));
                }
            }
        }

        return songs;
    }
}
