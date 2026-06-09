package com.vku.karaoke.utils;

import com.vku.karaoke.model.Song;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * TRẢ LỜI VẤN ĐÁP: Thực hiện yêu cầu về IOStream (Session 3).
 * Dùng luồng ký tự cấp cao BufferedWriter và BufferedReader phối hợp bộ đệm để tối ưu hóa hiệu năng
 * đọc ghi file văn bản dạng dòng (.txt), giúp sao lưu dữ liệu vĩnh viễn đề phòng mất điện/sập nguồn.
 */
public class FileIOUtil {

    /**
     * Ghi danh sách bài hát hiện tại từ database ra một file văn bản .txt tách nhau bởi dấu gạch đứng (|)
     */
    public static void saveSongsToTxt(List<Song> songs, String filePath) throws IOException {
        // Dùng FileWriter kết hợp BufferedWriter để ghi file theo từng dòng chữ văn bản ổn định
        try (BufferedWriter bw = new BufferedWriter(new FileWriter(filePath))) {
            for (Song s : songs) {
                String line = s.getId() + "|" + s.getTitle() + "|" + s.getArtist() + "|" + s.getGenre();
                bw.write(line);
                bw.newLine(); // Xuống dòng cho bản ghi tiếp theo
            }
        }
    }

    /**
     * Đọc ngược lại dữ liệu từ file .txt lên cấu trúc List nhằm phục hồi hoặc nhập nhanh dữ liệu.
     */
    public static List<Song> loadSongsFromTxt(String filePath) throws IOException {
        List<Song> list = new ArrayList<>();
        File file = new File(filePath);
        if (!file.exists()) return list; // Nếu file không tồn tại thì trả về danh sách rỗng tránh lỗi

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                String[] parts = line.split("\\|");
                if (parts.length == 4) {
                    list.add(new Song(parts[0], parts[1], parts[2], parts[3]));
                }
            }
        }
        return list;
    }
}