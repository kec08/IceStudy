package com.icestudy.domain.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.icestudy.global.exception.BusinessException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.math.BigInteger;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.RSAPublicKeySpec;
import java.util.Base64;

@Component
public class AppleTokenVerifier {

    private static final String APPLE_KEYS_URL = "https://appleid.apple.com/auth/keys";
    private static final String APPLE_ISSUER = "https://appleid.apple.com";

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    /**
     * Apple identityToken(JWT)을 검증하고 subject(Apple 유저 ID)를 반환
     */
    public String verifyAndGetSubject(String identityToken) {
        try {
            String[] parts = identityToken.split("\\.");
            if (parts.length != 3) {
                throw new IllegalArgumentException("Invalid JWT format");
            }

            String headerJson = new String(Base64.getUrlDecoder().decode(parts[0]));
            String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]));

            JsonNode header = objectMapper.readTree(headerJson);
            JsonNode payload = objectMapper.readTree(payloadJson);

            // 1. issuer 확인
            String issuer = payload.get("iss").asText();
            if (!APPLE_ISSUER.equals(issuer)) {
                throw new IllegalArgumentException("Invalid issuer: " + issuer);
            }

            // 2. 토큰 만료 확인
            long exp = payload.get("exp").asLong();
            if (System.currentTimeMillis() / 1000 > exp) {
                throw new IllegalArgumentException("Token expired");
            }

            // 3. Apple 공개키로 서명 검증
            String kid = header.get("kid").asText();
            String alg = header.get("alg").asText();
            PublicKey publicKey = fetchApplePublicKey(kid);

            String signatureAlgorithm = "SHA256withRSA";
            if ("RS384".equals(alg)) signatureAlgorithm = "SHA384withRSA";
            else if ("RS512".equals(alg)) signatureAlgorithm = "SHA512withRSA";

            Signature sig = Signature.getInstance(signatureAlgorithm);
            sig.initVerify(publicKey);
            sig.update((parts[0] + "." + parts[1]).getBytes());
            byte[] signatureBytes = Base64.getUrlDecoder().decode(parts[2]);

            if (!sig.verify(signatureBytes)) {
                throw new IllegalArgumentException("Invalid signature");
            }

            // 4. subject(Apple 유저 고유 ID) 반환
            return payload.get("sub").asText();

        } catch (Exception e) {
            throw new BusinessException("AUTH_004", "Apple 인증에 실패했습니다: " + e.getMessage(), HttpStatus.UNAUTHORIZED);
        }
    }

    private PublicKey fetchApplePublicKey(String kid) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(APPLE_KEYS_URL))
                .GET()
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        JsonNode keys = objectMapper.readTree(response.body()).get("keys");

        for (JsonNode key : keys) {
            if (kid.equals(key.get("kid").asText())) {
                byte[] nBytes = Base64.getUrlDecoder().decode(key.get("n").asText());
                byte[] eBytes = Base64.getUrlDecoder().decode(key.get("e").asText());
                RSAPublicKeySpec spec = new RSAPublicKeySpec(
                        new BigInteger(1, nBytes),
                        new BigInteger(1, eBytes)
                );
                return KeyFactory.getInstance("RSA").generatePublic(spec);
            }
        }

        throw new IllegalArgumentException("Apple public key not found for kid: " + kid);
    }
}
