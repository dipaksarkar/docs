const fs = require("fs");
const path = require("path");

// Function to convert absolute URLs to relative URLs in HTML files
function rewriteLinksInFile(filePath, depth) {
  let content = fs.readFileSync(filePath, "utf8");

  // Calculate the appropriate number of "../" for the current file's depth
  const relativePrefix = "../".repeat(depth);

  // Replace absolute URLs with dynamically calculated relative URLs
  content = content.replace(/(href|src)="\/([^"]*)"/g, (match, p1, p2) => {
    if (p1 === "href" && p2 === "") {
      // Special case for href="/", convert to href="/index.html"
      return `${p1}="${relativePrefix}index.html"`;
    } else if (p1 === "href" && p2.endsWith("/")) {
      // Convert href="/path/" to href="/path/index.html"
      return `${p1}="${relativePrefix}${p2}index.html"`;
    }
    return `${p1}="${relativePrefix}${p2}"`;
  });

  // Save the modified file
  fs.writeFileSync(filePath, content, "utf8");
}

// Recursively process all HTML files in the dist folder
function processDistFolder(distDir, currentDepth = 0) {
  fs.readdirSync(distDir).forEach((file) => {
    const filePath = path.join(distDir, file);
    const stat = fs.statSync(filePath);

    if (stat.isDirectory()) {
      processDistFolder(filePath, currentDepth + 1); // Recurse into subdirectories
    } else if (file.endsWith(".html")) {
      rewriteLinksInFile(filePath, currentDepth);
    }
  });
}

// Define the dist folder path (adjust as needed)
const distPath = path.join(__dirname, "../docs/.vitepress/dist");

// Process the dist folder
processDistFolder(distPath);

console.log("Links rewritten to relative paths based on directory depth.");
