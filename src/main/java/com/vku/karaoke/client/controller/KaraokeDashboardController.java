package com.vku.karaoke.client.controller;

import com.vku.karaoke.client.MainClientApp;
import com.vku.karaoke.client.network.ClientConnection;
import com.vku.karaoke.model.Playlist;
import com.vku.karaoke.model.Request;
import com.vku.karaoke.model.Response;
import com.vku.karaoke.model.SearchHistory;
import com.vku.karaoke.model.Song;
import com.vku.karaoke.model.User;
import javafx.application.Platform;
import javafx.collections.FXCollections;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.stage.Stage;

import java.util.List;

public class KaraokeDashboardController {
    @FXML
    private Label lblWelcome;

    @FXML
    private TextField txtSearch;

    @FXML
    private TextField txtId;

    @FXML
    private TextField txtTitle;

    @FXML
    private TextField txtArtist;

    @FXML
    private TextField txtGenre;

    @FXML
    private TableView<Song> tableSongs;

    @FXML
    private TableColumn<Song, String> colId;

    @FXML
    private TableColumn<Song, String> colTitle;

    @FXML
    private TableColumn<Song, String> colArtist;

    @FXML
    private TableColumn<Song, String> colGenre;

    @FXML
    private Button btnAdd;

    @FXML
    private Button btnUpdate;

    @FXML
    private Button btnDelete;

    @FXML
    private Button btnImportTxt;

    @FXML
    private ListView<Playlist> listPlaylists;

    @FXML
    private TextField txtPlaylistName;

    @FXML
    private TableView<Song> tablePlaylistSongs;

    @FXML
    private TableColumn<Song, String> colPlId;

    @FXML
    private TableColumn<Song, String> colPlTitle;

    @FXML
    private TableColumn<Song, String> colPlArtist;

    @FXML
    private TableView<SearchHistory> tableHistory;

    @FXML
    private TableColumn<SearchHistory, String> colKeyword;

    @FXML
    private TableColumn<SearchHistory, String> colSearchedAt;

    private ClientConnection connection;
    private User currentUser;

    @FXML
    public void initialize() {
        colId.setCellValueFactory(new PropertyValueFactory<>("id"));
        colTitle.setCellValueFactory(new PropertyValueFactory<>("title"));
        colArtist.setCellValueFactory(new PropertyValueFactory<>("artist"));
        colGenre.setCellValueFactory(new PropertyValueFactory<>("genre"));

        colPlId.setCellValueFactory(new PropertyValueFactory<>("id"));
        colPlTitle.setCellValueFactory(new PropertyValueFactory<>("title"));
        colPlArtist.setCellValueFactory(new PropertyValueFactory<>("artist"));

        colKeyword.setCellValueFactory(new PropertyValueFactory<>("keyword"));
        colSearchedAt.setCellValueFactory(new PropertyValueFactory<>("searchedAt"));

        tableSongs.getSelectionModel().selectedItemProperty().addListener((obs, oldSong, newSong) -> {
            if (newSong != null) {
                txtId.setText(newSong.getId());
                txtTitle.setText(newSong.getTitle());
                txtArtist.setText(newSong.getArtist());
                txtGenre.setText(newSong.getGenre());
            }
        });

        listPlaylists.getSelectionModel().selectedItemProperty().addListener((obs, oldPlaylist, newPlaylist) -> {
            if (newPlaylist != null) {
                loadPlaylistSongs(newPlaylist);
            }
        });
    }

    public void initUserData(ClientConnection connection, User user) {
        this.connection = connection;
        this.currentUser = user;

        lblWelcome.setText("Xin chào: " + user.getUsername() + " | Quyền: " + user.getRole());

        boolean isAdmin = user.isAdmin();
        btnAdd.setDisable(!isAdmin);
        btnUpdate.setDisable(!isAdmin);
        btnDelete.setDisable(!isAdmin);
        btnImportTxt.setDisable(!isAdmin);

        txtId.setEditable(isAdmin);
        txtTitle.setEditable(isAdmin);
        txtArtist.setEditable(isAdmin);
        txtGenre.setEditable(isAdmin);

        loadSongs();
        loadPlaylists();
        loadHistory();
    }

    @FXML
    void handleRefresh(ActionEvent event) {
        loadSongs();
        loadPlaylists();
        loadHistory();
        clearSongForm();
    }

    @FXML
    void handleSearch(ActionEvent event) {
        String keyword = txtSearch.getText().trim();

        if (keyword.isEmpty()) {
            loadSongs();
            return;
        }

        try {
            Response response = connection.send(new Request("SEARCH", keyword));
            if (response.isSuccess()) {
                tableSongs.setItems(FXCollections.observableArrayList((List<Song>) response.getData()));
                loadHistory();
            } else {
                showAlert("Lỗi tìm kiếm", response.getMessage());
            }
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleInsert(ActionEvent event) {
        if (!currentUser.isAdmin()) {
            showAlert("Không đủ quyền", "Chỉ ADMIN mới được thêm bài hát.");
            return;
        }

        Song song = getSongFromForm();
        if (song == null) {
            return;
        }

        try {
            Response response = connection.send(new Request("ADD", song));
            showAlert("Kết quả", response.getMessage());
            loadSongs();
            clearSongForm();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleUpdate(ActionEvent event) {
        if (!currentUser.isAdmin()) {
            showAlert("Không đủ quyền", "Chỉ ADMIN mới được sửa bài hát.");
            return;
        }

        Song song = getSongFromForm();
        if (song == null) {
            return;
        }

        try {
            Response response = connection.send(new Request("UPDATE", song));
            showAlert("Kết quả", response.getMessage());
            loadSongs();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleDelete(ActionEvent event) {
        if (!currentUser.isAdmin()) {
            showAlert("Không đủ quyền", "Chỉ ADMIN mới được xóa bài hát.");
            return;
        }

        String id = txtId.getText().trim();
        if (id.isEmpty()) {
            showAlert("Thiếu dữ liệu", "Chọn bài hát cần xóa.");
            return;
        }

        try {
            Response response = connection.send(new Request("DELETE", id));
            showAlert("Kết quả", response.getMessage());
            loadSongs();
            clearSongForm();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleExportTxt(ActionEvent event) {
        sendSimpleCommand("EXPORT_TXT");
    }

    @FXML
    void handleImportTxt(ActionEvent event) {
        sendSimpleCommand("IMPORT_TXT");
        loadSongs();
    }

    @FXML
    void handleExportXml(ActionEvent event) {
        sendSimpleCommand("EXPORT_XML");
    }

    @FXML
    void handleCreatePlaylist(ActionEvent event) {
        String name = txtPlaylistName.getText().trim();

        if (name.isEmpty()) {
            showAlert("Thiếu dữ liệu", "Nhập tên playlist.");
            return;
        }

        try {
            Response response = connection.send(new Request("PLAYLIST_CREATE", name));
            showAlert("Kết quả", response.getMessage());
            txtPlaylistName.clear();
            loadPlaylists();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleDeletePlaylist(ActionEvent event) {
        Playlist playlist = listPlaylists.getSelectionModel().getSelectedItem();

        if (playlist == null) {
            showAlert("Thiếu dữ liệu", "Chọn playlist cần xóa.");
            return;
        }

        try {
            Response response = connection.send(new Request("PLAYLIST_DELETE", playlist.getId()));
            showAlert("Kết quả", response.getMessage());
            tablePlaylistSongs.getItems().clear();
            loadPlaylists();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleAddSongToPlaylist(ActionEvent event) {
        Playlist playlist = listPlaylists.getSelectionModel().getSelectedItem();
        Song song = tableSongs.getSelectionModel().getSelectedItem();

        if (playlist == null || song == null) {
            showAlert("Thiếu dữ liệu", "Chọn playlist và chọn bài hát ở bảng danh sách bài hát.");
            return;
        }

        try {
            String data = playlist.getId() + "|" + song.getId();
            Response response = connection.send(new Request("PLAYLIST_ADD_SONG", data));
            showAlert("Kết quả", response.getMessage());
            loadPlaylistSongs(playlist);
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleRemoveSongFromPlaylist(ActionEvent event) {
        Playlist playlist = listPlaylists.getSelectionModel().getSelectedItem();
        Song song = tablePlaylistSongs.getSelectionModel().getSelectedItem();

        if (playlist == null || song == null) {
            showAlert("Thiếu dữ liệu", "Chọn playlist và chọn bài hát trong playlist.");
            return;
        }

        try {
            String data = playlist.getId() + "|" + song.getId();
            Response response = connection.send(new Request("PLAYLIST_REMOVE_SONG", data));
            showAlert("Kết quả", response.getMessage());
            loadPlaylistSongs(playlist);
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    @FXML
    void handleClearHistory(ActionEvent event) {
        sendSimpleCommand("CLEAR_HISTORY");
        loadHistory();
    }

    @FXML
    void handleLogout(ActionEvent event) {
        try {
            if (connection != null) {
                connection.close();
            }

            FXMLLoader loader = new FXMLLoader(MainClientApp.class.getResource("/login.fxml"));
            Scene scene = new Scene(loader.load(), 430, 330);
            scene.getStylesheets().add(MainClientApp.class.getResource("/style.css").toExternalForm());

            Stage stage = (Stage) ((Node) event.getSource()).getScene().getWindow();
            stage.setTitle("Đăng nhập hệ thống Karaoke");
            stage.setScene(scene);
            stage.centerOnScreen();
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    private void loadSongs() {
        try {
            Response response = connection.send(new Request("GET_ALL"));
            if (response.isSuccess()) {
                tableSongs.setItems(FXCollections.observableArrayList((List<Song>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải bài hát", e.getMessage());
        }
    }

    private void loadPlaylists() {
        try {
            Response response = connection.send(new Request("PLAYLISTS"));
            if (response.isSuccess()) {
                listPlaylists.setItems(FXCollections.observableArrayList((List<Playlist>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải playlist", e.getMessage());
        }
    }

    private void loadPlaylistSongs(Playlist playlist) {
        try {
            Response response = connection.send(new Request("PLAYLIST_SONGS", playlist.getId()));
            if (response.isSuccess()) {
                tablePlaylistSongs.setItems(FXCollections.observableArrayList((List<Song>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải bài hát trong playlist", e.getMessage());
        }
    }

    private void loadHistory() {
        try {
            Response response = connection.send(new Request("GET_HISTORY"));
            if (response.isSuccess()) {
                tableHistory.setItems(FXCollections.observableArrayList((List<SearchHistory>) response.getData()));
            }
        } catch (Exception e) {
            showAlert("Lỗi tải lịch sử", e.getMessage());
        }
    }

    private Song getSongFromForm() {
        String id = txtId.getText().trim();
        String title = txtTitle.getText().trim();
        String artist = txtArtist.getText().trim();
        String genre = txtGenre.getText().trim();

        if (id.isEmpty() || title.isEmpty() || artist.isEmpty() || genre.isEmpty()) {
            showAlert("Thiếu dữ liệu", "Không được để trống mã, tên bài hát, ca sĩ, thể loại.");
            return null;
        }

        return new Song(id, title, artist, genre);
    }

    private void clearSongForm() {
        txtId.clear();
        txtTitle.clear();
        txtArtist.clear();
        txtGenre.clear();
    }

    private void sendSimpleCommand(String command) {
        try {
            Response response = connection.send(new Request(command));
            showAlert("Kết quả", response.getMessage());
        } catch (Exception e) {
            showAlert("Lỗi", e.getMessage());
        }
    }

    private void showAlert(String title, String message) {
        Platform.runLater(() -> {
            Alert alert = new Alert(Alert.AlertType.INFORMATION);
            alert.setTitle(title);
            alert.setHeaderText(null);
            alert.setContentText(message);
            alert.showAndWait();
        });
    }
}
