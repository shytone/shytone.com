# Build script: runs jekyll build then post-processes encrypted files
# Scans source _posts/ for encrypt: true front matter, then encrypts corresponding output HTML
require 'fileutils'
require 'openssl'
require 'base64'
require 'yaml'

DEST   = '_site'
SOURCE = '.'
KEY    = ENV['ENCRYPT_KEY'] || ENV['JEKYLL_ENCRYPT_KEY']

def encrypt_html(filepath, key)
  html = File.read(filepath, encoding: 'UTF-8')
  return unless html.include?('<!--more-->')

  parts = html.split('<!--more-->', 2)
  return unless parts.length == 2

  header    = parts[0]
  body_html = parts[1]

  key_digest = OpenSSL::Digest::SHA256.digest(key)
  iv         = OpenSSL::Random.random_bytes(12)
  cipher     = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  cipher.key = key_digest
  cipher.iv  = iv
  enc = cipher.update(body_html) + cipher.final
  tag = cipher.auth_tag
  encrypted = Base64.strict_encode64(iv + tag + enc)

  box = <<~HTML
  <div class="encrypt-wrapper">
    <div class="encrypt-box" data-payload="#{encrypted}">
      <div class="encrypt-icon">🔐</div>
      <h3 lang="zh">🔒 此文章已加密</h3>
      <h3 lang="en" style="display:none">🔒 This Article is Encrypted</h3>
      <p lang="zh" style="color:rgba(255,255,255,0.7);margin:8px 0 16px;">输入密钥解锁文章内容</p>
      <p lang="en" style="display:none;color:rgba(255,255,255,0.7);margin:8px 0 16px;">Enter the key to decrypt</p>
      <div class="encrypt-input-row">
        <input type="password" class="encrypt-key-input"
               placeholder="输入密钥 / Enter key"
               onkeydown="if(event.key==='Enter')document.querySelector('.encrypt-unlock-btn').click()" />
        <button class="encrypt-unlock-btn" onclick="DecryptBox.unlock(this)">解锁 / Decrypt</button>
      </div>
      <p class="encrypt-error" style="display:none;color:#fc4d50;margin-top:8px;font-size:0.9rem;" lang="zh">❌ 密钥错误，请重试</p>
      <p class="encrypt-error" style="display:none;color:#fc4d50;margin-top:8px;font-size:0.9rem;" lang="en">❌ Wrong key, please try again</p>
    </div>
    <div class="encrypt-body" style="display:none"></div>
  </div>
  HTML

  File.write(filepath, header + '<!--more-->' + box, encoding: 'UTF-8')
  puts "[ENCRYPT] #{filepath}"
end

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
    # Remove date prefix: 2026-05-06-test-encrypt -> test-encrypt
    slug = slug.sub(/^\d{4}-\d{2}-\d{2}-/, '')
    title = fm['title'] || slug

    # Search for the output file by title/slug in the dest
    # Jekyll writes to: [category]/YYYY/MM/DD/[slug].html
    candidates = []
    Dir.glob(File.join(DEST, '**', '*.html')).each do |html_path|
      next unless File.file?(html_path)
      html = File.read(html_path, encoding: 'UTF-8')
      # Match by title in front matter (data-encrypt) or by URL slug
      if html.include?("title=\"#{title}\"") || html.include?("data-encrypt=\"true\"") || html_path.include?(slug)
        candidates << html_path
      end
    end

    if candidates.length == 1
      encrypt_html(candidates[0], KEY)
    elsif candidates.length > 1
      puts "[WARN] Multiple candidates for #{src_path}: #{candidates.join(', ')}"
    else
      puts "[WARN] No output found for: #{src_path} (title=#{title})"
    end
  rescue => e
    puts "[ERROR] #{src_path}: #{e.message}"
  end
end