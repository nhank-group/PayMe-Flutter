package com.kpay.sdk.example.kpay_flutter;

import android.util.Base64;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;

import javax.crypto.*;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class CryptoAES {
//    public static String exampleKey ="Ge13YEobKVPAxEb1y8DYd5BpwFhSzlMaI5oK0/umFFhdn1ZK/chcRfMjjqUYadTwMR1SwjSK1Y+vcMaJ/5dkFg==";
//    public static String privateKey= "3zA9HDejj1GnyVK0";

    public static byte[] ivbyte = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    public static String encrypt(String input, String key) {
        try {
            byte[] bytes = input.getBytes(StandardCharsets.UTF_8);
            Cipher ciper = Cipher.getInstance("AES/CBC/PKCS5Padding");
            IvParameterSpec iv = new IvParameterSpec(ivbyte,0, ciper.getBlockSize());
            SecretKey secret = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "AES");

            ciper.init(Cipher.ENCRYPT_MODE, secret,iv);
            byte[] result =  ciper.doFinal(bytes);
            return Base64.encodeToString(result, Base64.NO_WRAP);
        } catch (Exception e) {
            System.out.println(e);
        }
        return null;
    }

}