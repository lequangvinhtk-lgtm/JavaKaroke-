package com.vku.karaoke.client.controller;

import com.vku.karaoke.model.Song;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.stage.Stage;

import java.io.*;
import java.net.Socket;
import java.util.List;

/**
 * TRẢ LỜI VẤN ĐÁP: Trung tâm xử lý giao diện bài hát kết nối liên hoàn Máy chủ.
 * Toàn bộ các hành vi CRUD không thực hiện trực tiếp xuống DB mà gửi gói tin mạng Socket.
 */
public class KaraokeDashboardController {

    @FXML private Label lblWelcome;
    @FXML private TextField txtSearch, txtId, txtTitle, txtArtist, txtGenre;
    @FXML private TableView<Song> tableSongs;
    @FXML private TableColumn<Song, String> colId, colTitle, colArtist, colGenre;

    @FXML private Button btnAdd, btnUpdate, btnDelete;

    private Socket socket;
    private ObjectOutputStream out;
    private ObjectInputStream in;

    private String loggedInUser;
    private String userRole;

    @FXML
    public void initialize() {
        colId.setCellValueFactory(new PropertyValueFactory<>("id"));
        colTitle.setCellValueFactory(new PropertyValueFactory<>("title"));
        colArtist.setCellValueFactory(new PropertyValueFactory<>("artist"));
        colGenre.setCellValueFactory(new PropertyValueFactory<>("genre"));

        tableSongs.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            if (newVal != null) {
                txtId.setText(newVal.getId());
                txtTitle.setText(newVal.getTitle());
                txtArtist.setText(newVal.getArtist());
                txtGenre.setText(newVal.getGenre());
            }
        });

        connectToServer();
    }

    public void initUserData(String username, String role) {
        this.loggedInUser = username;
        this.userRole = role;
        lblWelcome.setText("Xin chào cán bộ: " + username + " [" + role + "]");

        if ("USER".equalsIgnoreCase(role)) {
            btnAdd.setDisable(true);
            btnUpdate.setDisable(true);
            btnDelete.setDisable(true);
            txtId.setEditable(false);
            txtTitle.setEditable(false);
            txtArtist.setEditable(false);
            txtGenre.setEditable(false);
        }

        refreshData();
    }

    private void connectToServer() {
        try {
            socket = new Socket("localhost", 9999);
            // FIX LỖI 4: flush() ngay sau khi tạo ObjectOutputStream để tránh deadlock.
            // ObjectOutputStream gửi một header 4 byte khi khởi tạo.
            // Nếu không flush, header này nằm trong bộ đệm, server cũng đang chờ header
            // đó để tạo ObjectInputStream → cả hai bên block lẫn nhau mãi mãi.
            out = new ObjectOutputStream(socket.getOutputStream());
            out.flush(); // ← DÒNG NÀY PHẢI CÓ
            in = new ObjectInputStream(socket.getInputStream());
        } catch (IOException e) {
            showNotify("Lỗi Kết Nối Mạng", "Không thể liên kết đường truyền mạng với Máy chủ!");
        }
    }

    @SuppressWarnings("unchecked")
    private void refreshData() {
        try {
            out.writeObject("GET_ALL");
            out.flush();

            List<Song> songs = (List<Song>) in.readObject();
            ObservableList<Song> obsList = FXCollections.observableArrayList(songs);

            Platform.runLater(() -> tableSongs.setItems(obsList));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @FXML
    void handleRefresh(ActionEvent event) {
        refreshData();
        clearInputs();
    }

    @SuppressWarnings("unchecked")
    @FXML
    void handleSearch(ActionEvent event) {
        String keyword = txtSearch.getText().trim();
        if (keyword.isEmpty()) {
            refreshData();
            return;
        }
        try {
            out.writeObject("SEARCH|" + keyword);
            out.flush();

            List<Song> result = (List<Song>) in.readObject();
            tableSongs.setItems(FXCollections.observableArrayList(result));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @FXML
    void handleInsert(ActionEvent event) {
        if (checkInputsEmpty()) return;
        try {
            Song s = new Song(txtId.getText().trim(), txtTitle.getText().trim(), txtArtist.getText().trim(), txtGenre.getText().trim());
            out.writeObject("ADD");
            out.writeObject(s);
            out.flush();

            String status = (String) in.readObject();
            if ("SUCCESS".equals(status)) {
                showNotify("Thêm Thành Công", "Đã chèn bản ghi bài hát karaoke lên hệ thống!");
                refreshData();
                clearInputs();
            } else {
                showNotify("Thất Bại", "Mã bài hát bị trùng lặp hoặc lỗi hệ thống xử lý!");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @FXML
    void handleUpdate(ActionEvent event) {
        if (checkInputsEmpty()) return;
        try {
            Song s = new Song(txtId.getText().trim(), txtTitle.getText().trim(), txtArtist.getText().trim(), txtGenre.getText().trim());
            out.writeObject("UPDATE");
            out.writeObject(s);
            out.flush();

            String status = (String) in.readObject();
            if ("SUCCESS".equals(status)) {
                showNotify("Cập Nhật Thành Công", "Thông tin bài hát karaoke đã được làm mới!");
                refreshData();
            } else {
                showNotify("Lỗi", "Không thể cập nhật thông tin bài hát!");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @FXML
    void handleDelete(ActionEvent event) {
        String id = txtId.getText().trim();
        if (id.isEmpty()) {
            showNotify("Lưu ý", "Vui lòng chọn bài hát Karaoke cần xóa!");
            return;
        }
        try {
            out.writeObject("DELETE|" + id);
            out.flush();

            String status = (String) in.readObject();
            if ("SUCCESS".equals(status)) {
                showNotify("Xóa Bản Ghi", "Bài hát đã được gỡ bỏ khỏi hệ thống Database!");
                refreshData();
                clearInputs();
            } else {
                showNotify("Lỗi", "Không thể thực hiện lệnh xóa dữ liệu!");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @FXML
    void handleExportTxt(ActionEvent event) {
        try {
            out.writeObject("EXPORT_TXT");
            out.flush();
            String status = (String) in.readObject();
            if ("EXPORT_TXT_SUCCESS".equals(status)) {
                showNotify("IOStream Sao Lưu", "Hệ thống máy chủ Server đã xuất file văn bản backup_songs.txt thành công!");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @FXML
    void handleExportXml(ActionEvent event) {
        try {
            out.writeObject("EXPORT_XML");
            out.flush();
            String status = (String) in.readObject();
            if ("EXPORT_XML_SUCCESS".equals(status)) {
                showNotify("Xuất Cây Dữ Liệu XML", "Đã tạo tập tin dữ liệu chia sẻ cấu trúc định dạng backup_songs.xml tại Server máy chủ!");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    @FXML
    void handleLogout(ActionEvent event) {
        try {
            if (socket != null) socket.close();

            Parent root = FXMLLoader.load(getClass().getResource("/login.fxml"));
            Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
            stage.setScene(new Scene(root, 400, 300));
            stage.setTitle("Đăng Nhập Hệ Thống Karaoke");
            stage.centerOnScreen();
        } catch (Exception e) { e.printStackTrace(); }
    }

    private boolean checkInputsEmpty() {
        if (txtId.getText().trim().isEmpty() || txtTitle.getText().trim().isEmpty() ||
                txtArtist.getText().trim().isEmpty() || txtGenre.getText().trim().isEmpty()) {
            showNotify("Lỗi Nhập Liệu", "Vui lòng không để trống bất cứ ô biểu mẫu nào!");
            return true;
        }
        return false;
    }

    private void clearInputs() {
        txtId.clear(); txtTitle.clear(); txtArtist.clear(); txtGenre.clear();
    }

    private void showNotify(String title, String content) {
        Platform.runLater(() -> {
            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle(title);
            alert.setHeaderText(null);
            alert.setContentText(content);
            alert.showAndWait();
        });
    }
}