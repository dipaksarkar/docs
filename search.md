If you want to search for files that contain a specific text string ("my-search-test") inside them, you can use the `grep` command on Linux/macOS or the `findstr` command on Windows.

### On macOS/Linux:

```bash
cd /path/to/your/folder
grep -r "my-search-test" *
```

This command recursively searches for the specified text string in all files within the current directory and its subdirectories.

### On Windows:

```batch
cd \path\to\your\folder
findstr /s /i /m "my-search-test" *
```

This command also searches for the specified text string in all files within the current directory and its subdirectories. The `/i` flag makes the search case-insensitive, and the `/m` flag displays only the file names.

Replace "/path/to/your/folder" or "\path\to\your\folder" with the actual path to the folder you want to search.

Remember to adjust the search string ("my-search-test") as needed. If you encounter issues or want more specific results, additional options and parameters for these commands are available in their respective documentation (`man grep` for Linux/macOS, `findstr /?` for Windows).