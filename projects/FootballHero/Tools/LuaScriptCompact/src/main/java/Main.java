import net.sf.json.JSONObject;
import sun.misc.BASE64Encoder;
import sun.misc.IOUtils;

import javax.crypto.*;
import javax.crypto.spec.DESKeySpec;
import java.io.*;
import java.util.HashMap;

public class Main {

    private static final String SOURCE_FOLDER = "../../Resources/scripts";
    private static final String TARGET_FILE_NAME = "../../Resources/game.bin";

    private HashMap<String, String> mContent = new HashMap<String, String>();
    private byte[] encryptedContent;
    private int padding;


    public static void main(String[] arr) {
        Main m = new Main();
        File f = new File(SOURCE_FOLDER);
        m.loadContentFromFile(f);
        m.decrypt();
        m.saveContent();

    }

    private void loadContentFromFile(File file) {
        if (file.isFile()) {
            String extension = file.getName();
            extension = extension.substring(extension.lastIndexOf("."));
            //System.out.println("extension: " + extension);
            if (extension.equalsIgnoreCase(".lua")) {
                String fileKey = file.getAbsolutePath().substring(file.getAbsolutePath().lastIndexOf("scripts"));
                fileKey = fileKey.substring(0, fileKey.lastIndexOf("."));
                fileKey = fileKey.replaceAll("/", ".");

                try {
                    FileReader reader = new FileReader(file);
                    BufferedReader bufferedReader = new BufferedReader(reader);

                    String c = "";
                    String l;
                    while ((l = bufferedReader.readLine()) != null) {
                        c += l;
                        c += "\n";
                    }
                    mContent.put(fileKey, c);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        } else if (file.isDirectory()) {
            File[] files = file.listFiles();
            for (int i = 0; i < files.length; i++) {
                loadContentFromFile(files[i]);
            }
        }
    }

    private void saveContent() {
        String content = new String(encryptedContent);

        File f = new File(TARGET_FILE_NAME);
        try {
            //create an object of FileOutputStream
            FileOutputStream fos = new FileOutputStream(new File(TARGET_FILE_NAME));

            //create an object of BufferedOutputStream
            BufferedOutputStream bos = new BufferedOutputStream(fos);

            bos.write(encryptedContent);
            //bos.write(padding);

            bos.close();
            fos.close();

        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    private HashMap<String, String> getContent() {
        return mContent;
    }

    private void decrypt() {
        String content = JSONObject.fromObject(this.getContent()).toString();
        try {
            SecretKeyFactory sf = SecretKeyFactory.getInstance("DES");
            byte[] in = content.getBytes("UTF-8");

            Cipher c = Cipher.getInstance("DES/ECB/PKCS5Padding");
            c.init(Cipher.ENCRYPT_MODE, sf.generateSecret(new DESKeySpec(
                    "gooddoggy".getBytes())));
            //encryptedContent = c.doFinal(in);
            encryptedContent = content.getBytes();
            padding = encryptedContent.length - in.length;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
