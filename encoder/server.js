const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs-extra");
const { v4: uuidv4 } = require("uuid");
const cors = require("cors");
const IonCubeEncoder = require("./services/ioncube-encoder");
const config = require("./config/config");

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static("public"));

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, "uploads");
    fs.ensureDirSync(uploadDir);
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}-${file.originalname}`;
    cb(null, uniqueName);
  },
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    if (
      file.mimetype === "application/zip" ||
      file.mimetype === "application/x-zip-compressed" ||
      path.extname(file.originalname).toLowerCase() === ".zip"
    ) {
      cb(null, true);
    } else {
      cb(new Error("Only ZIP files are allowed"), false);
    }
  },
});

// Routes
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "OK",
    message: "IonCube Encoder API is running",
    timestamp: new Date().toISOString(),
  });
});

// Main encoding endpoint
app.post("/encode", upload.single("zipFile"), async (req, res) => {
  const jobId = uuidv4();

  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "No ZIP file uploaded",
      });
    }

    console.log(
      `[${jobId}] Starting encoding job for file: ${req.file.originalname}`
    );

    const encoder = new IonCubeEncoder(jobId);
    const result = await encoder.processZipFile(req.file.path, {
      // IonCube encoding options
      phpVersion: req.body.phpVersion || "8.1",
      optimization: req.body.optimization || "max",
      obfuscation: req.body.obfuscation === "true",
      expiration: req.body.expiration || null,
      allowedServers: req.body.allowedServers || null,
    });

    if (result.success) {
      // Set headers for file download
      res.setHeader("Content-Type", "application/zip");
      res.setHeader(
        "Content-Disposition",
        `attachment; filename="encoded-${req.file.originalname}"`
      );

      // Stream the encoded ZIP file
      const fileStream = fs.createReadStream(result.encodedZipPath);
      fileStream.pipe(res);

      // Cleanup after streaming
      fileStream.on("end", () => {
        encoder.cleanup();
        console.log(`[${jobId}] Job completed successfully`);
      });

      fileStream.on("error", (error) => {
        console.error(`[${jobId}] Error streaming file:`, error);
        encoder.cleanup();
        if (!res.headersSent) {
          res.status(500).json({
            success: false,
            message: "Error streaming encoded file",
          });
        }
      });
    } else {
      encoder.cleanup();
      res.status(500).json({
        success: false,
        message: result.message || "Encoding failed",
      });
    }
  } catch (error) {
    console.error(`[${jobId}] Error in encoding process:`, error);
    res.status(500).json({
      success: false,
      message: "Internal server error during encoding",
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        success: false,
        message: "File too large. Maximum size is 100MB",
      });
    }
  }

  res.status(500).json({
    success: false,
    message: error.message || "Internal server error",
  });
});

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    success: false,
    message: "Endpoint not found",
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`IonCube Encoder API server running on port ${PORT}`);
  console.log(`Access the web interface at: http://localhost:${PORT}`);
});

module.exports = app;
