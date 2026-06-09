package com.vku.karaoke.server.dao;

import com.vku.karaoke.utils.DBUtil;
import java.sql.*;

/**
 * TRẢ LỜI VẤN ĐÁP: Phục vụ chức năng quản lý xác thực đăng nhập bảo mật (Session 6 - Security).
 * Kiểm tra tài khoản tồn tại và trả về chính xác Quyền/Vai trò hệ thống của người dùng đăng nhập.
 */
public class UserDAO {

    /**
     * Xác thực thông tin đăng nhập từ tài khoản và mật khẩu của client gửi lên.
     * @return Chuỗi chứa Vai trò ("ADMIN" hoặc "USER") nếu thông tin chính xác, ngược lại trả về null.
     */
    public String authenticate(String username, String password) throws SQLException {
        String sql = "SELECT role FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("role"); // Trả về vai trò lấy được từ cơ sở dữ liệu
                }
            }
        }
        return null; // Trả về null nếu thông tin đăng nhập sai lệch
    }
}