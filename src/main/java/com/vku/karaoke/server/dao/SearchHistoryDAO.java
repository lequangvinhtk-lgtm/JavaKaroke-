package com.vku.karaoke.server.dao;

import com.vku.karaoke.model.SearchHistory;
import com.vku.karaoke.utils.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class SearchHistoryDAO {
    public void saveKeyword(int userId, String keyword) throws Exception {
        if (keyword == null || keyword.trim().isEmpty()) {
            return;
        }

        String sql = "INSERT INTO search_history(user_id, keyword) VALUES (?, ?)";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, keyword.trim());
            ps.executeUpdate();
        }
    }

    public List<SearchHistory> findByUser(int userId) throws Exception {
        List<SearchHistory> historyList = new ArrayList<>();
        String sql = """
                SELECT id, user_id, keyword, searched_at
                FROM search_history
                WHERE user_id = ?
                ORDER BY searched_at DESC
                LIMIT 100
                """;

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    historyList.add(new SearchHistory(
                            rs.getInt("id"),
                            rs.getInt("user_id"),
                            rs.getString("keyword"),
                            String.valueOf(rs.getTimestamp("searched_at"))
                    ));
                }
            }
        }

        return historyList;
    }

    public boolean clearByUser(int userId) throws Exception {
        String sql = "DELETE FROM search_history WHERE user_id = ?";

        try (Connection connection = DBUtil.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        }
    }
}
