package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.Song;
import com.vku.karaoke.utils.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TRẢ LỜI VẤN ĐÁP: Thực hiện yêu cầu JDBC (Session 5 - DB).
 * Toàn bộ các hàm truy vấn bắt buộc sử dụng PreparedStatement thay vì Statement thông thường.
 * Tại sao? Để tránh lỗi SQL Injection (bảo mật hệ thống) và tối ưu hóa tốc độ thực thi câu lệnh lặp lại.
 */
public class SongDAO {

    // Lấy toàn bộ danh sách bài hát đang lưu trữ
    public List<Song> getAllSongs() throws SQLException {
        List<Song> list = new ArrayList<>();
        String sql = "SELECT * FROM songs";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Song(rs.getString("id"), rs.getString("title"), rs.getString("artist"), rs.getString("genre")));
            }
        }
        return list;
    }

    // Tìm kiếm bài hát theo từ khóa tên hoặc ca sĩ gần đúng
    public List<Song> searchSongs(String keyword) throws SQLException {
        List<Song> list = new ArrayList<>();
        String sql = "SELECT * FROM songs WHERE title LIKE ? OR artist LIKE ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            // Thiết lập giá trị tham số an toàn cho dấu chấm hỏi
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Song(rs.getString("id"), rs.getString("title"), rs.getString("artist"), rs.getString("genre")));
                }
            }
        }
        return list;
    }

    // Thêm một bài hát mới vào Database
    public boolean addSong(Song s) throws SQLException {
        String sql = "INSERT INTO songs (id, title, artist, genre) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getId());
            ps.setString(2, s.getTitle());
            ps.setString(3, s.getArtist());
            ps.setString(4, s.getGenre());
            return ps.executeUpdate() > 0; // Trả về true nếu thêm thành công ít nhất 1 dòng
        }
    }

    // Cập nhật thông tin bài hát dựa trên Mã bài hát (Khóa chính)
    public boolean updateSong(Song s) throws SQLException {
        String sql = "UPDATE songs SET title=?, artist=?, genre=? WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, s.getTitle());
            ps.setString(2, s.getArtist());
            ps.setString(3, s.getGenre());
            ps.setString(4, s.getId());
            return ps.executeUpdate() > 0;
        }
    }

    // Xóa bài hát khỏi hệ thống
    public boolean deleteSong(String id) throws SQLException {
        String sql = "DELETE FROM songs WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        }
    }
}