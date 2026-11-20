package dao;


import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Băm và kiểm tra mật khẩu (PBKDF2-HmacSHA256, có muối ngẫu nhiên).
 * Định dạng lưu trong cột User4.passWord:  pbkdf2$<số vòng>$<muối base64>$<băm base64>
 */
public class PasswordUtil4 {

    private static final String PREFIX = "pbkdf2";
    private static final int ITERATIONS = 120000;
    private static final int SALT_BYTES = 16;
    private static final int KEY_BITS = 256;
    private static final SecureRandom RANDOM = new SecureRandom();

    private PasswordUtil4() {
    }

    /** Băm mật khẩu để lưu vào CSDL. */
    public static String hash(String password) {
        byte[] salt = new byte[SALT_BYTES];
        RANDOM.nextBytes(salt);
        byte[] dk = derive(password, salt, ITERATIONS);
        return PREFIX + "$" + ITERATIONS + "$"
                + Base64.getEncoder().encodeToString(salt) + "$"
                + Base64.getEncoder().encodeToString(dk);
    }

    /** So khớp mật khẩu nhập vào với chuỗi đã lưu. */
    public static boolean verify(String password, String stored) {
        if (password == null || stored == null) {
            return false;
        }
        String[] p = stored.split("\\$");
        if (p.length != 4 || !PREFIX.equals(p[0])) {
            return false;
        }
        try {
            int iterations = Integer.parseInt(p[1]);
            byte[] salt = Base64.getDecoder().decode(p[2]);
            byte[] expected = Base64.getDecoder().decode(p[3]);
            byte[] actual = derive(password, salt, iterations);
            return MessageDigest.isEqual(expected, actual);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }

    private static byte[] derive(String password, byte[] salt, int iterations) {
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, KEY_BITS);
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e);
        } finally {
            spec.clearPassword();
        }
    }

    /** Dùng để sinh băm cho dữ liệu mẫu: java -cp ... util.PasswordUtil4 matKhau */
    public static void main(String[] args) {
        for (String a : args) {
            System.out.println(new String(hash(a).getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8));
        }
    }
}
