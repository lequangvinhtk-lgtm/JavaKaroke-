package com.vku.karaoke.utils;

import com.vku.karaoke.model.Song;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.File;
import java.util.List;

public class XMLUtil {
    private XMLUtil() {
    }

    public static void exportSongsToXML(List<Song> songs, String filePath) throws Exception {
        Document doc = DocumentBuilderFactory.newInstance()
                .newDocumentBuilder()
                .newDocument();

        Element root = doc.createElement("karaokeSongs");
        doc.appendChild(root);

        for (Song song : songs) {
            Element songNode = doc.createElement("song");
            songNode.setAttribute("id", song.getId());

            append(doc, songNode, "title", song.getTitle());
            append(doc, songNode, "artist", song.getArtist());
            append(doc, songNode, "genre", song.getGenre());

            root.appendChild(songNode);
        }

        javax.xml.transform.Transformer transformer =
                TransformerFactory.newInstance().newTransformer();

        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

        transformer.transform(new DOMSource(doc), new StreamResult(new File(filePath)));
    }

    private static void append(Document doc, Element parent, String tag, String value) {
        Element element = doc.createElement(tag);
        element.appendChild(doc.createTextNode(value == null ? "" : value));
        parent.appendChild(element);
    }
}
