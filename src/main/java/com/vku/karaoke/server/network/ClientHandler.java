package com.vku.karaoke.server.network;

import com.vku.karaoke.model.Song;
import com.vku.karaoke.server.dao.SongDAO;
import com.vku.karaoke.server.dao.UserDAO;
import com.vku.karaoke.utils.FileIOUtil;
import com.vku.karaoke.utils.XMLUtil;

import java.io.*;
import java.net.Socket;
import java.util.List;

/**
 * TRẢ LỜI VẤN ĐÁP: Thực hiện yêu cầu về Multithreading (Session 2) và Networking (Session 7).
 * Lớp này kế thừa giao diện Runnable để chạy song song trên một phân luồng Thread độc lập.
 * Tại sao phải làm thế? Giúp máy chủ phục vụ đồng thời hàng trăm người dùng cùng truy cập một lúc,
 * không bắt người dùng này phải đứng đợi người dùng khác xử lý xong, đảm bảo máy chủ không treo (Non-blocking server).
 */
public class ClientHandler implements Runnable {
    private Socket socket;
    private ObjectInputStream in;
    private ObjectOutputStream out;
    private SongDAO songDAO;
    private UserDAO userDAO;

    public ClientHandler(Socket socket) {
        this.socket = socket;
        this.songDAO = new SongDAO();
        this.userDAO = new UserDAO();
    }

    @Override
    public void run() {
        try {
            // FIX LỖI 5: Bắt buộc flush() ngay sau khi tạo ObjectOutputStream
            // để gửi header stream đi trước, tránh deadlock khi cả hai bên cùng
            // chờ nhau tạo ObjectInputStream.
            out = new ObjectOutputStream(socket.getOutputStream());
            out.flush(); // ← DÒNG NÀY PHẢI CÓ
            in = new ObjectInputStream(socket.getInputStream());

            while (true) {
                // Đọc lệnh yêu cầu (Protocol String) được gửi từ client
                String request = (String) in.readObject();
                if (request == null) break;

                System.out.println("[SERVER LOG] Đang xử lý yêu cầu: " + request);
                String[] parts = request.split("\\|");
                String command = parts[0];

                switch (command) {
                    case "LOGIN":
                        String user = parts[1];
                        String pass = parts[2];
                        String role = userDAO.authenticate(user, pass);
                        if (role != null) {
                            out.writeObject("LOGIN_SUCCESS|" + role);
                        } else {
                            out.writeObject("LOGIN_FAILED");
                        }
                        break;

                    case "GET_ALL":
                        out.writeObject(songDAO.getAllSongs());
                        break;

                    case "SEARCH":
                        String key = parts[1];
                        out.writeObject(songDAO.searchSongs(key));
                        break;

                    case "ADD":
                        Song songAdd = (Song) in.readObject();
                        boolean addRes = songDAO.addSong(songAdd);
                        out.writeObject(addRes ? "SUCCESS" : "FAILED");
                        break;

                    case "UPDATE":
                        Song songUpdate = (Song) in.readObject();
                        boolean upRes = songDAO.updateSong(songUpdate);
                        out.writeObject(upRes ? "SUCCESS" : "FAILED");
                        break;

                    case "DELETE":
                        String deleteId = parts[1];
                        boolean delRes = songDAO.deleteSong(deleteId);
                        out.writeObject(delRes ? "SUCCESS" : "FAILED");
                        break;

                    case "EXPORT_TXT":
                        List<Song> currentSongsForTxt = songDAO.getAllSongs();
                        FileIOUtil.saveSongsToTxt(currentSongsForTxt, "backup_songs.txt");
                        out.writeObject("EXPORT_TXT_SUCCESS");
                        break;

                    case "EXPORT_XML":
                        List<Song> currentSongsForXml = songDAO.getAllSongs();
                        XMLUtil.exportToXML(currentSongsForXml, "backup_songs.xml");
                        out.writeObject("EXPORT_XML_SUCCESS");
                        break;

                    default:
                        out.writeObject("UNKNOWN_COMMAND");
                        break;
                }
                out.flush();
            }
        } catch (EOFException e) {
            System.out.println("[SERVER INFO] Một Client vừa thoát khỏi hệ thống ứng dụng.");
        } catch (Exception e) {
            System.err.println("[SERVER ERROR] Lỗi phân luồng xử lý yêu cầu: " + e.getMessage());
        } finally {
            try {
                if (in != null) in.close();
                if (out != null) out.close();
                if (socket != null) socket.close();
            } catch (IOException ignored) {}
        }
    }
}