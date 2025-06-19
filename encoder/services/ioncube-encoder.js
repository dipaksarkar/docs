const fs = require("fs-extra");
const path = require("path");
const { exec } = require("child_process");
const { promisify } = require("util");
const extractZip = require("extract-zip");
const archiver = require("archiver");
const config = require("../config/config");

const execAsync = promisify(exec);

class IonCubeEncoder {
  constructor(jobId) {
    this.jobId = jobId;
    this.tempDir = path.join(config.tempDir, jobId);
    this.extractDir = path.join(this.tempDir, "extracted");
    this.encodedDir = path.join(this.tempDir, "encoded");
    this.outputZipPath = path.join(config.outputDir, `encoded-${jobId}.zip`);

    // Ensure directories exist
    this.initializeDirectories();
  }

  async initializeDirectories() {
    await fs.ensureDir(this.tempDir);
    await fs.ensureDir(this.extractDir);
    await fs.ensureDir(this.encodedDir);
    await fs.ensureDir(config.outputDir);
  }

  async processZipFile(zipFilePath, options = {}) {
    try {
      console.log(`[${this.jobId}] Starting ZIP file processing`);

      // Extract the uploaded ZIP file
      await this.extractZipFile(zipFilePath, this.extractDir);

      // Copy all files to encoded directory first
      await fs.copy(this.extractDir, this.encodedDir);

      // Find and encode PHP files
      const phpFiles = await this.findPhpFiles(this.encodedDir);
      console.log(
        `[${this.jobId}] Found ${phpFiles.length} PHP files to encode`
      );

      if (phpFiles.length > 0) {
        await this.encodePHPFiles(phpFiles, options);
      }

      // Create the final ZIP file
      await this.createEncodedZip();

      // Clean up uploaded file
      await fs.remove(zipFilePath);

      return {
        success: true,
        encodedZipPath: this.outputZipPath,
        filesEncoded: phpFiles.length,
      };
    } catch (error) {
      console.error(`[${this.jobId}] Error processing ZIP file:`, error);
      return {
        success: false,
        message: error.message,
      };
    }
  }

  async extractZipFile(zipPath, extractPath) {
    console.log(`[${this.jobId}] Extracting ZIP file`);
    await extractZip(zipPath, { dir: extractPath });
  }

  async findPhpFiles(directory) {
    const phpFiles = [];

    const scanDirectory = async (dir) => {
      const items = await fs.readdir(dir);

      for (const item of items) {
        const fullPath = path.join(dir, item);
        const stat = await fs.stat(fullPath);

        if (stat.isDirectory()) {
          // Skip excluded directories
          if (!this.shouldExcludeDirectory(item)) {
            await scanDirectory(fullPath);
          }
        } else if (stat.isFile()) {
          // Check if it's a PHP file and not excluded
          if (this.isPhpFile(fullPath) && !this.shouldExcludeFile(item)) {
            phpFiles.push(fullPath);
          }
        }
      }
    };

    await scanDirectory(directory);
    return phpFiles;
  }

  isPhpFile(filePath) {
    const ext = path.extname(filePath).toLowerCase();
    return config.encoding.allowedExtensions.includes(ext);
  }

  shouldExcludeFile(fileName) {
    return config.encoding.excludeFiles.includes(fileName);
  }

  shouldExcludeDirectory(dirName) {
    return config.encoding.excludeDirs.includes(dirName);
  }

  async encodePHPFiles(phpFiles, options) {
    console.log(`[${this.jobId}] Starting IonCube encoding`);

    // Check if IonCube encoder is available
    if (!(await this.checkIonCubeAvailable())) {
      throw new Error(
        "IonCube encoder not found. Please install IonCube encoder first."
      );
    }

    const phpVersion = options.phpVersion || config.encoding.defaultPhpVersion;
    const optimization =
      options.optimization || config.encoding.defaultOptimization;

    for (const phpFile of phpFiles) {
      try {
        await this.encodeFile(phpFile, phpVersion, optimization, options);
        console.log(
          `[${this.jobId}] Encoded: ${path.relative(this.encodedDir, phpFile)}`
        );
      } catch (error) {
        console.error(
          `[${this.jobId}] Failed to encode ${phpFile}:`,
          error.message
        );
        // Continue with other files even if one fails
      }
    }
  }

  async checkIonCubeAvailable() {
    try {
      await execAsync(`"${config.ioncubePath}" --version`);
      return true;
    } catch (error) {
      return false;
    }
  }

  async encodeFile(filePath, phpVersion, optimization, options) {
    let command = `"${config.ioncubePath}"`;

    // Basic encoding options
    command += ` --target ${phpVersion}`;
    command += ` --optimize ${optimization}`;
    command += ` --replace-target`;

    // Additional options
    if (options.obfuscation) {
      command += ` --obfuscate all`;
    }

    if (options.expiration) {
      command += ` --expire-on ${options.expiration}`;
    }

    if (options.allowedServers) {
      const servers = Array.isArray(options.allowedServers)
        ? options.allowedServers.join(",")
        : options.allowedServers;
      command += ` --allowed-server ${servers}`;
    }

    // Add the file to encode
    command += ` "${filePath}"`;

    await execAsync(command);
  }

  async createEncodedZip() {
    console.log(`[${this.jobId}] Creating encoded ZIP file`);

    return new Promise((resolve, reject) => {
      const output = fs.createWriteStream(this.outputZipPath);
      const archive = archiver("zip", {
        zlib: { level: 9 }, // Maximum compression
      });

      output.on("close", () => {
        console.log(
          `[${this.jobId}] ZIP file created: ${archive.pointer()} total bytes`
        );
        resolve();
      });

      archive.on("error", (err) => {
        reject(err);
      });

      archive.pipe(output);

      // Add all files from encoded directory
      archive.directory(this.encodedDir, false);

      archive.finalize();
    });
  }

  async cleanup() {
    try {
      console.log(`[${this.jobId}] Cleaning up temporary files`);
      await fs.remove(this.tempDir);

      // Optional: Remove output file after some time
      if (config.cleanup.autoCleanup) {
        setTimeout(async () => {
          try {
            await fs.remove(this.outputZipPath);
            console.log(`[${this.jobId}] Cleaned up output file`);
          } catch (error) {
            console.error(
              `[${this.jobId}] Error cleaning up output file:`,
              error
            );
          }
        }, config.cleanup.tempFilesTTL);
      }
    } catch (error) {
      console.error(`[${this.jobId}] Error during cleanup:`, error);
    }
  }
}

module.exports = IonCubeEncoder;
