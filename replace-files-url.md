# How to Replace File URLs with Hash-based Paths in Database and Blade Files

This guide explains how to replace URLs like  
`https://bouncifypro.com/file/email-verification-illustration.svg?hash=40d9b4d8f51f822bb6ca7a19e858b97a`  
with  
`/uploads/files/40d9b4d8f51f822bb6ca7a19e858b97a.svg`  
in your database **and** in all `.blade.php` files, for different database systems and operating systems.

---

## 1. Database Replacement

### MySQL

```sql
UPDATE pages 
SET data = REGEXP_REPLACE(
  data, 
  'https:\\\\\/\\\\\/bouncifypro\\.com\\\\\/file\\\\\/([^?]+)\\.([a-zA-Z0-9]+)\\?hash=([a-zA-Z0-9]+)',
  '\\\\/uploads\\\\/files\\\\/\\3.\\2'
);
```

### PostgreSQL

```sql
UPDATE pages 
SET data = REGEXP_REPLACE(
  data,
  'https:\\\/\\\/bouncifypro\.com\\\/file\\\/[^?]+\.([a-zA-Z0-9]+)\?hash=([a-zA-Z0-9]+)',
  '\\/uploads\\/files\\/\\2.\\1',
  'g'
);
```

### SQLite

SQLite does **not** support regex replacements directly. You must use multiple `REPLACE` statements for each file:

```sql
UPDATE pages 
SET data = REPLACE(
  data,
  'https:\/\/bouncifypro.com\/file\/email-verification-illustration.svg?hash=40d9b4d8f51f822bb6ca7a19e858b97a',
  '\/uploads\/files\/40d9b4d8f51f822bb6ca7a19e858b97a.svg'
);
```
Repeat for each unique file.

---

## 2. Blade File Replacement

### Pattern

Replace URLs like:  
`https://nowride.co.uk/file/filename.png?hash=abcdef1234567890`  
with:  
`/uploads/files/abcdef1234567890.png`

### Bash Command (All OS)

#### **macOS**

```bash
find resources -type f -name "*.blade.php" -exec sed -i '' -E 's#https://nowride\.co\.uk/file/[^?]+\.(png|jpg|jpeg|svg|gif)\?hash=([a-zA-Z0-9]+)#/uploads/files/\2.\1#g' {} +
```

#### **Linux**

```bash
find resources -type f -name "*.blade.php" -exec sed -i -E 's#https://nowride\.co\.uk/file/[^?]+\.(png|jpg|jpeg|svg|gif)\?hash=([a-zA-Z0-9]+)#/uploads/files/\2.\1#g' {} +
```

#### **Linux (with backup)**

```bash
find resources -type f -name "*.blade.php" -exec sed -i.bak -E 's#https://nowride\.co\.uk/file/[^?]+\.(png|jpg|jpeg|svg|gif)\?hash=([a-zA-Z0-9]+)#/uploads/files/\2.\1#g' {} +
```

- Adjust the domain and file extensions as needed.
- Always **backup your files** before running these commands.

---

## 3. Important Notes

1. **Backup your data and files** before running any replacements.
2. Test on a single record or file first.
3. Regex escaping can be tricky—double-check your results.
4. For SQLite, manual replacements are required for each file.

---

## 4. Example Test Command

Test on a single database record:

```sql
UPDATE pages SET data = ... WHERE id = 123;
```

Test on a single Blade file:

```bash
sed -i '' -E 's#https://nowride\.co\.uk/file/[^?]+\.(png|jpg|jpeg|svg|gif)\?hash=([a-zA-Z0-9]+)#/uploads/files/\2.\1#g' resources/views/pages/example.blade.php
```

---

**Need help with a different pattern or system? Let me know!**