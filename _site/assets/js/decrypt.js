/**
 * decrypt.js — AES-256-GCM 浏览器端解密
 * 配合 scripts/post-build-encrypt.rb 使用
 * 密钥算法：SHA256(passphrase) → 32字节 AES-256-GCM
 */
(function () {
  'use strict';

  var SALT = 'shytone-encrypt-v1'; // 固定盐（前端已知）

  function sha256(str) {
    // 使用 Web Crypto SHA-256
    return crypto.subtle.digest('SHA-256', new TextEncoder().encode(str))
      .then(function (buf) {
        return new Uint8Array(buf);
      });
  }

  function deriveKey(password) {
    // SHA256(passphrase) → 32 bytes key
    return sha256(password);
  }

  function base64ToBytes(b64) {
    var data = atob(b64);
    var bytes = new Uint8Array(data.length);
    for (var i = 0; i < data.length; i++) bytes[i] = data.charCodeAt(i);
    return bytes;
  }

  function decryptAES(ciphertextB64, password) {
    var bytes = base64ToBytes(ciphertextB64);
    var iv    = bytes.slice(0, 12);
    var authTag = bytes.slice(12, 28);
    var ciphertext = bytes.slice(28);

    return deriveKey(password).then(function (key) {
      return crypto.subtle.decrypt(
        { name: 'AES-GCM', iv: iv, tagLength: 128 },
        key,
        ciphertext
      ).then(function (plaintext) {
        return new TextDecoder().decode(plaintext);
      });
    });
  }

  window.DecryptBox = {
    unlock: function (btn) {
      var box = btn.closest('.encrypt-box');
      var password = box.querySelector('.encrypt-key-input').value;
      if (!password) return;

      decryptAES(box.getAttribute('data-payload'), password)
        .then(function (plaintext) {
          var body = box.nextElementSibling;
          body.innerHTML = plaintext;
          body.style.display = 'block';
          box.style.display = 'none';
          // Re-run language toggle to handle bilingual content
          if (window.toggleLang) toggleLang();
        })
        .catch(function () {
          var errors = box.querySelectorAll('.encrypt-error');
          errors.forEach(function (el) { el.style.display = 'block'; });
        });
    }
  };
})();