const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();

const MOMENT_HOME = '/home/pi/MomentCloud';
const MOMENT_URL = 'http://58.233.69.198/moment';

app.get('/list', (req, res) => {
    const dir = req.query.dir || 'upload';
    const ext = req.query.ext || '*';
    const fullPath = path.join(MOMENT_HOME, dir);

    fs.readdir(fullPath, (err, files) => {
        if (err) {
            return res.status(500).send('Error reading directory');
        }

        const filteredFiles = files.filter(file => {
            if (ext === '*') return true;
            return path.extname(file).toLowerCase() === `.${ext.toLowerCase()}`;
        });

        const fileList = filteredFiles.join('<br>');
        res.send(fileList);
    });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
