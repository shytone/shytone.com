# Build script: runs jekyll build then post-processes encrypted files
# Scans source _posts/ for encrypt: true front matter, then encrypts corresponding output HTML
require 'fileutils'
require 'openssl'
require 'base64'
require 'yaml'

DEST   = '_site'
SOURCE = '.'

# Minimal self-contained CSS for the encrypt box (dark theme)
ENCRYPT_CSS = <<~CSS
  *,*::before,*::after{box-sizing:border-box}
  body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:#1a1a2e;color:#e0e0e0;min-height:100vh;margin:0}
  .page-header{background:#16213e;border-bottom:1px solid #0f3460;padding:20px 0}
  .page-header .container{max-width:900px;margin:0 auto;padding:0 20px}
  .page-header h1{color:#e94560;margin:0;font-size:1.5rem}
  .article-header{padding:40px 0 20px;max-width:900px;margin:0 auto;padding-left:20px;padding-right:20px}
  .article-header h1{color:#e0e0e0;margin:0 0 8px;font-size:1.8rem}
  .article-meta{color:#888;font-size:0.85rem;margin-bottom:24px}
  .encrypt-wrapper{padding:40px 20px;max-width:900px;margin:0 auto}
  .encrypt-box{background:#16213e;border-radius:12px;padding:40px;max-width:480px;margin:0 auto;text-align:center;box-shadow:0 8px 32px rgba(0,0,0,0.4)}
  .encrypt-icon{font-size:3rem;margin-bottom:16px}
  .encrypt-box h3{color:#fff;margin:0 0 20px;font-size:1.2rem;font-weight:500}
  .encrypt-input-row{display:flex;gap:8px;margin-top:16px}
  .encrypt-key-input{flex:1;padding:10px 14px;border:1px solid #0f3460;border-radius:8px;background:#0a0a1a;color:#e0e0e0;font-size:1rem;outline:none}
  .encrypt-key-input:focus{border-color:#e94560}
  .encrypt-unlock-btn{padding:10px 20px;background:#e94560;color:#fff;border:none;border-radius:8px;cursor:pointer;font-size:1rem;white-space:nowrap}
  .encrypt-unlock-btn:hover{background:#d63850}
  .encrypt-error{margin-top:12px;color:#fc4d50;font-size:0.9rem}
  .encrypt-body{display:none}
  .article-footer{padding:40px 20px;border-top:1px solid #222;max-width:900px;margin:0 auto;font-size:0.85rem;color:#555}
  @media(max-width:520px){.encrypt-input-row{flex-direction:column}.encrypt-box{padding:24px}}
CSS

DECRYPT_JS = <<~JS
(function(){
  'use strict';
  var SALT='shytone-encrypt-v1';
  function sha256(str){return crypto.subtle.digest('SHA-256',new TextEncoder().encode(str)).then(function(b){return new Uint8Array(b)})}
  function deriveKey(pw){return sha256(pw)}
  function unlock(btn){
    var box=btn.closest('.encrypt-box');
    var input=box.querySelector('.encrypt-key-input');
    var err=box.querySelectorAll('.encrypt-error');
    var payload=box.getAttribute('data-payload');
    err.forEach(function(e){e.style.display='none'});
    deriveKey(input.value).then(function(key){
      try{
        var data=atob(payload);
        var bytes=new Uint8Array(atob(data).split('').map(function(c){return c.charCodeAt(0)}));
        var iv=bytes.slice(0,12);
        var tag=bytes.slice(12,28);
        var ct=bytes.slice(28);
        return crypto.subtle.decrypt({name:'AES-GCM',iv:iv},key,ct).then(function(pt){
          var dec=new TextDecoder().decode(pt);
          var body=box.closest('.encrypt-wrapper').querySelector('.encrypt-body');
          body.style.display='block';
          body.innerHTML=dec;
          box.style.display='none';
        });
      }catch(e){err.forEach(function(e){e.style.display='block'})}
    });
  }
  window.DecryptBox={unlock:unlock};
})();
JS

def build_complete_html(title, date_str, header_html, encrypted_payload)
  html = <<~HTML
  <!DOCTYPE html>
  <html lang="zh-Hans">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>#{title}</title>
    <link rel="stylesheet" href="/assets/css/main.css">
    <style>
  #{ENCRYPT_CSS}
    </style>
  </head>
  <body>
    <header class="page-header"><div class="container"><h1>#{title}</h1></div></header>
    <main>
      <div class="article-header">
        <h1>#{title}</h1>
        <p class="article-meta">#{date_str}</p>
      </div>
      <div class="encrypt-wrapper">
        <div class="encrypt-box" data-payload="#{encrypted_payload}">
          <div class="encrypt-icon">🔐</div>
          <h3>此文章已加密 / Encrypted</h3>
          <div class="encrypt-input-row">
            <input type="password" class="encrypt-key-input"
                   onkeydown="if(event.key==='Enter')DecryptBox.unlock(this)">
            <button class="encrypt-unlock-btn" onclick="DecryptBox.unlock(this)">解锁</button>
          </div>
          <p class="encrypt-error">❌ 密钥错误，请重试</p>
        </div>
        <div class="encrypt-body"></div>
      </div>
    </main>
    <footer class="article-footer">© shytone.com</footer>
    <script>
  #{DECRYPT_JS}
    </script>
  </body>
  </html>
  HTML
  html
end

def encrypt_html(filepath, key, title, date_str)
  html = File.read(filepath, encoding: 'UTF-8')
  return unless html.include?('<!--more-->')

  parts = html.split('<!--more-->', 2)
  return unless parts.length == 2

  header_html = parts[0]
  body_html   = parts[1]

  # Derive key: SHA256(passphrase) → 32 bytes
  key_digest = OpenSSL::Digest::SHA256.digest(key)
  iv         = OpenSSL::Random.random_bytes(12)
  cipher     = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  cipher.key = key_digest
  cipher.iv  = iv
  enc = cipher.update(body_html) + cipher.final
  tag = cipher.auth_tag  # auth_tag is set after final() for GCM
  encrypted = Base64.strict_encode64(iv + tag + enc)

  complete_html = build_complete_html(title, date_str, header_html, encrypted)
  File.write(filepath, complete_html, encoding: 'UTF-8')
  puts "[ENCRYPT] #{filepath} (#{complete_html.length} bytes)"
end

KEY = ENV['ENCRYPT_KEY'] || ENV['JEKYLL_ENCRYPT_KEY']

if KEY.nil? || KEY.empty?
  puts "[ENCRYPT] No ENCRYPT_KEY set, skipping post-build encryption"
  exit 0
end

# Scan source posts for encrypt: true
Dir.glob(File.join(SOURCE, '_posts', '*.md')).each do |src_path|
  begin
    content = File.read(src_path, encoding: 'UTF-8')
    next unless content.start_with?('---')
    fm_end = content.index('---', 3)
    next unless fm_end
    fm_text = content[3..fm_end-1]
    fm = YAML.safe_load(fm_text, permitted_classes: [Time])
    next unless fm.is_a?(Hash) && fm['encrypt'] == true

    slug = File.basename(src_path, '.md')
    slug = slug.sub(/^\d{4}-\d{2}-\d{2}-/, '')
    title = fm['title'] || slug
    date_str = fm['date'] ? fm['date'].strftime('%Y-%m-%d') : ''

    # Find output HTML file by slug in _site
    candidates = []
    Dir.glob(File.join(DEST, '**', '*.html')).each do |html_path|
      next unless File.file?(html_path)
      html = File.read(html_path, encoding: 'UTF-8')
      if html.include?("title=\"#{title}\"") || html.include?('data-encrypt="true"') || html_path.include?(slug)
        candidates << html_path
      end
    end

    if candidates.length == 1
      encrypt_html(candidates[0], KEY, title, date_str)
    elsif candidates.length > 1
      puts "[WARN] Multiple candidates for #{src_path}: #{candidates.join(', ')}"
    else
      puts "[WARN] No output found for: #{src_path} (title=#{title})"
    end
  rescue => e
    puts "[ERROR] #{src_path}: #{e.message}"
  end
end
