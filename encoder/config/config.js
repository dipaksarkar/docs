module.exports = {
  // IonCube encoder binary path
  ioncubePath: process.env.IONCUBE_PATH || "/usr/local/ioncube/ioncube_encoder",

  // Temporary directories
  tempDir: process.env.TEMP_DIR || "./temp",
  uploadsDir: process.env.UPLOADS_DIR || "./uploads",
  outputDir: process.env.OUTPUT_DIR || "./output",

  // Encoding settings
  encoding: {
    defaultPhpVersion: "8.1",
    supportedPhpVersions: [
      "5.6",
      "7.0",
      "7.1",
      "7.2",
      "7.3",
      "7.4",
      "8.0",
      "8.1",
      "8.2",
    ],
    defaultOptimization: "max",
    optimizationLevels: ["none", "low", "medium", "high", "max"],
    maxFileSize: 100 * 1024 * 1024, // 100MB
    allowedExtensions: [".php", ".inc", ".phtml"],
    excludeFiles: [
      "composer.json",
      "composer.lock",
      "package.json",
      "package-lock.json",
      ".env",
      ".env.example",
      "README.md",
      ".gitignore",
    ],
    excludeDirs: [
      "node_modules",
      ".git",
      ".svn",
      "vendor/bin",
      "storage/logs",
      "storage/cache",
      "storage/sessions",
      "bootstrap/cache",
    ],
  },

  // Cleanup settings
  cleanup: {
    tempFilesTTL: 3600000, // 1 hour in milliseconds
    autoCleanup: true,
  },

  // Logging
  logging: {
    level: process.env.LOG_LEVEL || "info",
    enableFileLogging: process.env.ENABLE_FILE_LOGGING === "true",
  },
};
