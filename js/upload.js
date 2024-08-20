const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const app = express();

const UPLOAD_PATH = path.join(__dirname, 'upload');
const ALLOWED_EXTENSIONS = ['mp4', 'ser2', 'xls', 'csv', 'mnt', 'gif', 'jpeg', 'jpg', 'png'];
const MAX_FILE_SIZE = 20 * 1024 * 1024; // 20 MB

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, UPLOAD_PATH);
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname);
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: MAX_FILE_SIZE },
    fileFilter: (req, file, cb) => {
        const ext = path.extname(file.originalname).toLowerCase().slice(1);
        if (ALLOWED_EXTENSIONS.includes(ext)) {
            cb(null, true);
        } else {
            cb(new Error('File type not allowed'), false);
        }
    }
});

app.post('/upload', upload.single('file'), (req, res) => {
    if (!req.file) {
        return res.status(400).send('No file uploaded');
    }

    const fileInfo = {
        name: req.file.originalname,
        type: req.file.mimetype,
        size: req.file.size
    };

    res.send(`Stored in: upload/${fileInfo.name}`);
});

app.use((err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).send('File is larger than 20 MB');
        }
    }
    if (err.message === 'File type not allowed') {
        return res.status(400).send('File type not allowed');
    }
    res.status(500).send('An error occurred during upload');
});

const PORT = 3001;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
