const fs = require('fs');
const path = require('path');
const glob = require('glob');

const directories = [
  { path: './docs/qaravel', titleTemplate: 'Qaravel' },
  { path: './docs/nitrofit28', titleTemplate: 'NitroFIT28' }
];

function addOrUpdateHeader(dirPath, titleTemplate) {
  const files = glob.sync(`${dirPath}/**/*.md`);
  files.forEach(filePath => {
    if (path.extname(filePath) === '.md') {
      fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
          console.error(`Error reading file ${filePath}:`, err);
          return;
        }

        const existingHeaderRegex = /---\s*titleTemplate:\s*(.*?)\s*---/;
        const newHeader = `---\ntitleTemplate: ${titleTemplate}\n---`;

        let updatedData;
        if (existingHeaderRegex.test(data)) {
          updatedData = data.replace(existingHeaderRegex, newHeader);
        } else {
          updatedData = `${newHeader}\n\n${data}`;
        }

        fs.writeFile(filePath, updatedData, 'utf8', err => {
          if (err) {
            console.error(`Error writing file ${filePath}:`, err);
          } else {
            console.log(`Header updated in file ${filePath}`);
          }
        });
      });
    }
  });
}

directories.forEach(dir => addOrUpdateHeader(dir.path, dir.titleTemplate));
