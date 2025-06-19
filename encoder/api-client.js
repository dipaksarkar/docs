/**
 * IonCube Encoder API Client Example
 *
 * This file demonstrates how to use the IonCube Encoder API
 * programmatically from Node.js applications.
 */

const fs = require("fs");
const path = require("path");
const FormData = require("form-data");
const fetch = require("node-fetch");

class IonCubeEncoderClient {
  constructor(apiUrl = "http://localhost:3000") {
    this.apiUrl = apiUrl;
  }

  /**
   * Check if the API server is healthy
   */
  async checkHealth() {
    try {
      const response = await fetch(`${this.apiUrl}/health`);
      const data = await response.json();
      return {
        success: response.ok,
        data: data,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Encode a PHP project ZIP file
   *
   * @param {string} zipFilePath - Path to the ZIP file to encode
   * @param {Object} options - Encoding options
   * @param {string} options.phpVersion - Target PHP version (default: '8.1')
   * @param {string} options.optimization - Optimization level (default: 'max')
   * @param {boolean} options.obfuscation - Enable obfuscation (default: false)
   * @param {string} options.expiration - Expiration date (YYYY-MM-DD)
   * @param {string} options.allowedServers - Comma-separated allowed servers
   * @param {string} outputPath - Path where to save the encoded ZIP file
   */
  async encodeProject(zipFilePath, options = {}, outputPath = null) {
    try {
      // Check if input file exists
      if (!fs.existsSync(zipFilePath)) {
        throw new Error(`Input file not found: ${zipFilePath}`);
      }

      // Prepare form data
      const form = new FormData();
      form.append("zipFile", fs.createReadStream(zipFilePath));

      // Add encoding options
      if (options.phpVersion) form.append("phpVersion", options.phpVersion);
      if (options.optimization)
        form.append("optimization", options.optimization);
      if (options.obfuscation)
        form.append("obfuscation", options.obfuscation.toString());
      if (options.expiration) form.append("expiration", options.expiration);
      if (options.allowedServers)
        form.append("allowedServers", options.allowedServers);

      console.log("Uploading and encoding project...");
      const response = await fetch(`${this.apiUrl}/encode`, {
        method: "POST",
        body: form,
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || `HTTP ${response.status}`);
      }

      // Determine output path
      if (!outputPath) {
        const inputFileName = path.basename(zipFilePath, ".zip");
        outputPath = path.join(
          path.dirname(zipFilePath),
          `encoded-${inputFileName}.zip`
        );
      }

      // Save the encoded file
      const buffer = await response.buffer();
      fs.writeFileSync(outputPath, buffer);

      return {
        success: true,
        outputPath: outputPath,
        size: buffer.length,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
      };
    }
  }

  /**
   * Encode multiple projects in batch
   */
  async encodeBatch(projects, options = {}) {
    const results = [];

    for (const project of projects) {
      console.log(`Encoding: ${project.input}`);
      const result = await this.encodeProject(
        project.input,
        options,
        project.output
      );
      results.push({
        input: project.input,
        output: project.output,
        ...result,
      });
    }

    return results;
  }
}

// Example usage
async function example() {
  const client = new IonCubeEncoderClient();

  // Check API health
  console.log("Checking API health...");
  const health = await client.checkHealth();
  if (!health.success) {
    console.error("API is not available:", health.error);
    return;
  }
  console.log("✅ API is healthy:", health.data.message);

  // Example 1: Simple encoding
  console.log("\n--- Example 1: Simple Encoding ---");
  const result1 = await client.encodeProject("./project.zip", {
    phpVersion: "8.1",
    optimization: "max",
  });

  if (result1.success) {
    console.log("✅ Encoding successful!");
    console.log(`Output: ${result1.outputPath}`);
    console.log(`Size: ${(result1.size / 1024).toFixed(2)} KB`);
  } else {
    console.error("❌ Encoding failed:", result1.error);
  }

  // Example 2: Advanced encoding with options
  console.log("\n--- Example 2: Advanced Encoding ---");
  const result2 = await client.encodeProject(
    "./advanced-project.zip",
    {
      phpVersion: "8.2",
      optimization: "high",
      obfuscation: true,
      expiration: "2024-12-31",
      allowedServers: "example.com,*.mydomain.com",
    },
    "./encoded-advanced-project.zip"
  );

  if (result2.success) {
    console.log("✅ Advanced encoding successful!");
    console.log(`Output: ${result2.outputPath}`);
  } else {
    console.error("❌ Advanced encoding failed:", result2.error);
  }

  // Example 3: Batch encoding
  console.log("\n--- Example 3: Batch Encoding ---");
  const projects = [
    { input: "./project1.zip", output: "./encoded1.zip" },
    { input: "./project2.zip", output: "./encoded2.zip" },
    { input: "./project3.zip", output: "./encoded3.zip" },
  ];

  const batchResults = await client.encodeBatch(projects, {
    phpVersion: "8.1",
    optimization: "max",
  });

  batchResults.forEach((result, index) => {
    if (result.success) {
      console.log(`✅ Project ${index + 1} encoded successfully`);
    } else {
      console.error(`❌ Project ${index + 1} failed:`, result.error);
    }
  });
}

// Command line usage
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log("IonCube Encoder API Client");
    console.log("");
    console.log("Usage:");
    console.log("  node api-client.js <input.zip> [output.zip] [options]");
    console.log("");
    console.log("Options:");
    console.log(
      "  --php-version <version>    Target PHP version (default: 8.1)"
    );
    console.log(
      "  --optimization <level>     Optimization level (default: max)"
    );
    console.log("  --obfuscation             Enable code obfuscation");
    console.log("  --expiration <date>       Expiration date (YYYY-MM-DD)");
    console.log("  --allowed-servers <list>  Comma-separated allowed servers");
    console.log(
      "  --api-url <url>          API server URL (default: http://localhost:3000)"
    );
    console.log("");
    console.log("Examples:");
    console.log("  node api-client.js project.zip");
    console.log(
      "  node api-client.js project.zip encoded.zip --php-version 8.2 --obfuscation"
    );
    process.exit(1);
  }

  async function runCLI() {
    const inputFile = args[0];
    let outputFile = args[1];

    // Parse options
    const options = {};
    let apiUrl = "http://localhost:3000";

    for (let i = 0; i < args.length; i++) {
      switch (args[i]) {
        case "--php-version":
          options.phpVersion = args[++i];
          break;
        case "--optimization":
          options.optimization = args[++i];
          break;
        case "--obfuscation":
          options.obfuscation = true;
          break;
        case "--expiration":
          options.expiration = args[++i];
          break;
        case "--allowed-servers":
          options.allowedServers = args[++i];
          break;
        case "--api-url":
          apiUrl = args[++i];
          break;
      }
    }

    // Default output file name
    if (!outputFile || outputFile.startsWith("--")) {
      const inputName = path.basename(inputFile, ".zip");
      outputFile = path.join(
        path.dirname(inputFile),
        `encoded-${inputName}.zip`
      );
    }

    const client = new IonCubeEncoderClient(apiUrl);

    console.log("🔐 IonCube Encoder API Client");
    console.log("============================");
    console.log(`Input:  ${inputFile}`);
    console.log(`Output: ${outputFile}`);
    console.log(`API:    ${apiUrl}`);
    console.log("");

    // Check health
    const health = await client.checkHealth();
    if (!health.success) {
      console.error("❌ API server is not available:", health.error);
      process.exit(1);
    }

    // Encode project
    console.log("Encoding project...");
    const result = await client.encodeProject(inputFile, options, outputFile);

    if (result.success) {
      console.log("✅ Encoding completed successfully!");
      console.log(`📁 Output file: ${result.outputPath}`);
      console.log(`📊 File size: ${(result.size / 1024).toFixed(2)} KB`);
    } else {
      console.error("❌ Encoding failed:", result.error);
      process.exit(1);
    }
  }

  runCLI().catch((error) => {
    console.error("❌ Unexpected error:", error);
    process.exit(1);
  });
}

module.exports = IonCubeEncoderClient;
