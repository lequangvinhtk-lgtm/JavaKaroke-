package com.vku.karaoke.utils;

import com.vku.karaoke.model.Song;
import org.w3c.dom.*;
import javax.xml.parsers.*;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.File;
import java.util.List;

/**
 * TRẢ LỜI VẤN ĐÁP: Thực hiện yêu cầu xử lý XML (Session 4).
 * Sử dụng kiến trúc DOM Parser (Document Object Model) tích hợp sẵn trong Java
 * dựng cây cấu trúc nút mạng cây phân tầng để bao đóng dữ liệu danh sách bài hát thành file dữ liệu XML trao đổi.
 */
public class XMLUtil {

    /**
     * Xuất danh sách bài hát thành cấu trúc file .xml chuẩn hóa cây dữ liệu dữ liệu
     */
    public static void exportToXML(List<Song> songs, String filePath) throws Exception {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.newDocument();

        // Tạo phần tử gốc <KaraokeSongs>
        Element root = doc.createElement("KaraokeSongs");
        doc.appendChild(root);

        for (Song s : songs) {
            // Tạo phần tử con <Song id="BH001">
            Element songNode = doc.createElement("Song");
            songNode.setAttribute("id", s.getId());

            // Thêm thẻ tên bài hát <Title>
            Element title = doc.createElement("Title");
            title.appendChild(doc.createTextNode(s.getTitle()));
            songNode.appendChild(title);

            // Thêm thẻ ca sĩ <Artist>
            Element artist = doc.createElement("Artist");
            artist.appendChild(doc.createTextNode(s.getArtist()));
            songNode.appendChild(artist);

            // Thêm thẻ thể loại <Genre>
            Element genre = doc.createElement("Genre");
            genre.appendChild(doc.createTextNode(s.getGenre()));
            songNode.appendChild(genre);

            // Gắn nút bài hát vào nút gốc
            root.appendChild(songNode);
        }

        // Thực hiện ghi cấu trúc DOM từ bộ nhớ Ram xuống ổ cứng cứng thông qua bộ chuyển đổi Transformer
        TransformerFactory tf = TransformerFactory.newInstance();
        Transformer transformer = tf.newTransformer();
        // Cấu hình thụt lề định dạng XML nhìn cho đẹp mắt, dễ đọc
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

        DOMSource source = new DOMSource(doc);
        StreamResult result = new StreamResult(new File(filePath));
        transformer.transform(source, result);
    }
}